# SpeedCheck Telemetry Backend API Specification

This document provides a comprehensive API specification and Go implementation blueprint for the backend service. It is designed to allow any Go developer to build a robust, production-ready service to sync and query client telemetry log files.

---

## 1. System Architecture

The client application (built with Flutter) collects telemetry data every 20 seconds and stores it locally. When a network connection is available, the client performs a multipart POST file upload to sync all unsynced data in a single batch.

```
+------------------+                   +------------------+                   +------------------+
|  Flutter Client  |                   |    Go Backend    |                   |  PostgreSQL / DB |
+--------+---------+                   +--------+---------+                   +--------+---------+
         |                                      |                                      |
         | 1. Periodic Telemetry Collection     |                                      |
         |    (Every 20 seconds)                |                                      |
         |                                      |                                      |
         | 2. Sync Triggered (Batch File Sync)  |                                      |
         |------------------------------------->|                                      |
         |    POST /api/v1/data/sync/           |                                      |
         |    Multipart file: "log" (JSON)      |                                      |
         |    Header: X-Device-Mac              | 3. Parse JSON File & Insert Batch    |
         |                                      |------------------------------------->|
         |                                      |    INSERT INTO telemetry_logs        |
         |<-------------------------------------|                                      |
         |    200 OK (Success Response)         |                                      |
         |                                      |                                      |
         | 4. Live Log Poll (Every 20 seconds)  |                                      |
         |------------------------------------->|                                      |
         |    GET /api/v1/logs/live?seconds=20  |                                      |
         |                                      | 5. Retrieve Recent Logs              |
         |                                      |------------------------------------->|
         |                                      |<-------------------------------------|
         |<-------------------------------------|                                      |
         |    JSON Live Telemetry Array         |                                      |
         |                                      |                                      |
         | 6. Get History by MAC                |                                      |
         |------------------------------------->|                                      |
         |    GET /api/v1/history?mac_address=X |                                      |
         |                                      | 7. Query Device History              |
         |                                      |------------------------------------->|
         |                                      |<-------------------------------------|
         |<-------------------------------------|                                      |
         |    JSON History Payload              |                                      |
```

---

## 2. API Specifications

### 2.1. Sync Telemetry File (`POST /api/v1/data/sync/`)
Syncs a batch of telemetry records packaged as a JSON file via a multipart file upload.

* **HTTP Method**: `POST`
* **Path**: `/api/v1/data/sync/`
* **Content-Type**: `multipart/form-data`
* **Required Headers**:
  * `X-Device-Mac` (string): The unique MAC address of the device uploading the file (e.g. `bc:a9:20:a1:0b:fe`).
* **Request Payload**:
  * `log` (Multipart File parameter): A JSON file representing the batch of telemetry logs.
* **JSON File Payload Structure**:
  An array of telemetry items matching the schema below:
  ```json
  [
    {
      "timestamp": "2026-07-15T12:00:00.000Z",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "accuracy": 15.2,
      "speed": 0.0,
      "carrier_name": "T-Mobile",
      "network_type": "Cellular",
      "technology": "5G",
      "cell_id": "12345678",
      "pci": 312,
      "tac": 1024,
      "earfcn_nrarfcn": 39650,
      "rsrp": -95,
      "rsrq": -12,
      "rssi": -80,
      "rssnr_ss_sinr": 15,
      "asu_level": 45,
      "signal_level": 4,
      "download_speed": 125.4,
      "upload_speed": 45.2,
      "ping": 25.0,
      "jitter": 3.5,
      "packet_loss": 0.0,
      "device_model": "Google Pixel 8",
      "android_version": "Android 14"
    }
  ]
  ```

* **Responses**:
  * **201 Created** (Sync Succeeded):
    ```json
    {
      "success": true,
      "message": "Successfully synchronized 12 log entries for device bc:a9:20:a1:0b:fe"
    }
    ```
  * **400 Bad Request** (Missing/malformed components):
    ```json
    {
      "success": false,
      "error": "Missing X-Device-Mac header or upload file 'log' is missing/corrupted"
    }
    ```
  * **500 Internal Server Error**:
    ```json
    {
      "success": false,
      "error": "Database persistence failure"
    }
    ```

---

### 2.2. Get Live Logs (`GET /api/v1/logs/live`)
Provides a pull-based endpoint that returns all logs uploaded or created within a configurable lookback window (default: last 20 seconds). Ideal for dashboard updates or live tail feeds.

* **HTTP Method**: `GET`
* **Path**: `/api/v1/logs/live`
* **Query Parameters**:
  * `seconds` (integer, optional, default: `20`): Lookback duration window in seconds.
  * `limit` (integer, optional, default: `100`): Limits the amount of returned logs.
* **Responses**:
  * **200 OK**:
    ```json
    [
      {
        "id": 482,
        "mac_address": "bc:a9:20:a1:0b:fe",
        "timestamp": "2026-07-15T12:30:40.000Z",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "accuracy": 15.2,
        "speed": 0.0,
        "carrier_name": "T-Mobile",
        "network_type": "Cellular",
        "technology": "5G",
        "cell_id": "12345678",
        "pci": 312,
        "tac": 1024,
        "earfcn_nrarfcn": 39650,
        "rsrp": -95,
        "rsrq": -12,
        "rssi": -80,
        "rssnr_ss_sinr": 15,
        "asu_level": 45,
        "signal_level": 4,
        "download_speed": 125.4,
        "upload_speed": 45.2,
        "ping": 25.0,
        "jitter": 3.5,
        "packet_loss": 0.0,
        "device_model": "Google Pixel 8",
        "android_version": "Android 14",
        "created_at": "2026-07-15T12:31:02.000Z"
      }
    ]
    ```

---

### 2.3. Get History by MAC Address (`GET /api/v1/history`)
Retrieves historical logs for a specific device filtered by its MAC address. Supports pagination and date ranges.

* **HTTP Method**: `GET`
* **Path**: `/api/v1/history`
* **Query Parameters**:
  * `mac_address` (string, required): The target device's MAC address.
  * `limit` (integer, optional, default: `50`): Number of logs per page.
  * `offset` (integer, optional, default: `0`): Page offset.
  * `start_date` (string, optional): ISO-8601/RFC3339 formatted start timestamp (e.g. `2026-07-15T00:00:00Z`).
  * `end_date` (string, optional): ISO-8601/RFC3339 formatted end timestamp (e.g. `2026-07-15T23:59:59Z`).
* **Responses**:
  * **200 OK**:
    ```json
    {
      "mac_address": "bc:a9:20:a1:0b:fe",
      "total_count": 184,
      "limit": 50,
      "offset": 0,
      "logs": [
        {
          "id": 480,
          "timestamp": "2026-07-15T12:29:40.000Z",
          "latitude": 37.7749,
          "longitude": -122.4194,
          "accuracy": 15.2,
          "speed": 0.0,
          "carrier_name": "T-Mobile",
          "network_type": "Cellular",
          "technology": "5G",
          "cell_id": "12345678",
          "pci": 312,
          "tac": 1024,
          "earfcn_nrarfcn": 39650,
          "rsrp": -95,
          "rsrq": -12,
          "rssi": -80,
          "rssnr_ss_sinr": 15,
          "asu_level": 45,
          "signal_level": 4,
          "download_speed": 120.1,
          "upload_speed": 40.5,
          "ping": 28.0,
          "jitter": 4.1,
          "packet_loss": 0.0,
          "device_model": "Google Pixel 8",
          "android_version": "Android 14",
          "created_at": "2026-07-15T12:31:02.000Z"
        }
      ]
    }
    ```
  * **400 Bad Request** (Missing `mac_address`):
    ```json
    {
      "success": false,
      "error": "mac_address query parameter is required"
    }
    ```

---

## 3. Database Schema

The database stores incoming telemetry entries mapped to the MAC address. Below is the SQL creation script (PostgreSQL/TimescaleDB or standard SQL compatible):

```sql
CREATE TABLE telemetry_logs (
    id SERIAL PRIMARY KEY,
    mac_address VARCHAR(17) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    accuracy DOUBLE PRECISION,
    speed DOUBLE PRECISION,
    carrier_name VARCHAR(100),
    network_type VARCHAR(20),       -- e.g., 'WiFi', 'Cellular', 'None'
    technology VARCHAR(20),         -- e.g., '2G', '3G', '4G', '5G', 'Unknown'
    cell_id VARCHAR(50),
    pci INTEGER,
    tac INTEGER,
    earfcn_nrarfcn INTEGER,
    rsrp INTEGER,
    rsrq INTEGER,
    rssi INTEGER,
    rssnr_ss_sinr INTEGER,
    asu_level INTEGER,
    signal_level INTEGER,
    download_speed DOUBLE PRECISION, -- Mbps
    upload_speed DOUBLE PRECISION,   -- Mbps
    ping DOUBLE PRECISION,           -- ms
    jitter DOUBLE PRECISION,         -- ms
    packet_loss DOUBLE PRECISION,    -- Percentage (0-100)
    device_model VARCHAR(100) NOT NULL,
    android_version VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Optimize queries for index-seeking history and pulling live logs
CREATE INDEX idx_telemetry_mac_address ON telemetry_logs (mac_address);
CREATE INDEX idx_telemetry_timestamp ON telemetry_logs (timestamp DESC);
CREATE INDEX idx_telemetry_created_at ON telemetry_logs (created_at DESC);
```

> [!NOTE]
> If high scale is expected, this table is a prime candidate for partition tables or TimescaleDB hypertables clustered on the `timestamp` column.

---

## 4. Go Implementation Blueprint (How to Develop)

Here is a template structure and implementation for the Go backend using the popular [Gin Web Framework](https://github.com/gin-gonic/gin) and [GORM ORM](https://gorm.io/).

### 4.1. Recommended Project Structure

```text
speedcheck-backend/
├── cmd/
│   └── api/
│       └── main.go         # Entry point: Configuration & Router initialization
├── internal/
│   ├── database/
│   │   └── database.go     # Connection & GORM models auto-migration
│   ├── handlers/
│   │   ├── sync.go         # POST /sync handler & JSON stream parser
│   │   ├── live.go         # GET /logs/live lookback query
│   │   └── history.go      # GET /history MAC address query
│   └── models/
│       └── telemetry.go    # Telemetry struct mapping JSON and DB schema
├── go.mod
├── go.sum
└── README.md
```

### 4.2. Go Dependency Setup (`go.mod`)

Ensure your environment initializes standard components:
```bash
go mod init speedcheck-backend
go get github.com/gin-gonic/gin
go get gorm.io/gorm
go get gorm.io/driver/postgres # Or gorm.io/driver/sqlite for testing
```

---

### 4.3. Code Implementations

#### Struct Model (`internal/models/telemetry.go`)

```go
package models

import (
	"time"
)

// TelemetryLog represents the telemetry logs table structure
type TelemetryLog struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	MACAddress     string    `gorm:"index;type:varchar(17);not null" json:"mac_address"`
	Timestamp      time.Time `gorm:"not null" json:"timestamp"`
	Latitude       *float64  `json:"latitude"`
	Longitude      *float64  `json:"longitude"`
	Accuracy       *float64  `json:"accuracy"`
	Speed          *float64  `json:"speed"`
	CarrierName    *string   `gorm:"type:varchar(100)" json:"carrier_name"`
	NetworkType    *string   `gorm:"type:varchar(20)" json:"network_type"`
	Technology     *string   `gorm:"type:varchar(20)" json:"technology"`
	CellID         *string   `gorm:"type:varchar(50)" json:"cell_id"`
	PCI            *int      `json:"pci"`
	TAC            *int      `json:"tac"`
	EarfcnNrarfcn  *int      `json:"earfcn_nrarfcn"`
	RSRP           *int      `json:"rsrp"`
	RSRQ           *int      `json:"rsrq"`
	RSSI           *int      `json:"rssi"`
	RssnrSsSinr    *int      `json:"rssnr_ss_sinr"`
	AsuLevel       *int      `json:"asu_level"`
	SignalLevel    *int      `json:"signal_level"`
	DownloadSpeed  *float64  `json:"download_speed"`
	UploadSpeed    *float64  `json:"upload_speed"`
	Ping           *float64  `json:"ping"`
	Jitter         *float64  `json:"jitter"`
	PacketLoss     *float64  `json:"packet_loss"`
	DeviceModel    string    `gorm:"type:varchar(100);not null" json:"device_model"`
	AndroidVersion string    `gorm:"type:varchar(50);not null" json:"android_version"`
	CreatedAt      time.Time `gorm:"default:CURRENT_TIMESTAMP;not null" json:"created_at"`
}
```

#### Database Helper (`internal/database/database.go`)

```go
package database

import (
	"fmt"
	"log"
	"speedcheck-backend/internal/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func InitDB(dsn string) {
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	fmt.Println("Database connection established.")

	// Perform Auto-Migration
	err = DB.AutoMigrate(&models.TelemetryLog{})
	if err != nil {
		log.Fatalf("Auto-Migration failed: %v", err)
	}
	fmt.Println("Database migration completed.")
}
```

#### Sync Handler (`internal/handlers/sync.go`)

This handler receives the uploaded JSON file under multipart field `log`, parses it, injects the `mac_address` from the header `X-Device-Mac`, and saves all records using GORM's batch insert capabilities.

```go
package handlers

import (
	"encoding/json"
	"net/http"
	"speedcheck-backend/internal/database"
	"speedcheck-backend/internal/models"

	"github.com/gin-gonic/gin"
)

// SyncLogsHandler handles client log batch uploads
func SyncLogsHandler(c *gin.Context) {
	// Retrieve MAC Address header
	macAddress := c.GetHeader("X-Device-Mac")
	if macAddress == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Missing X-Device-Mac header",
		})
		return
	}

	// Retrieve Multipart File
	fileHeader, err := c.FormFile("log")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Missing log upload file parameter",
		})
		return
	}

	// Open the uploaded file
	file, err := fileHeader.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to open uploaded log file",
		})
		return
	}
	defer file.Close()

	// Parse JSON content
	var logs []models.TelemetryLog
	decoder := json.NewDecoder(file)
	if err := decoder.Decode(&logs); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Uploaded file is not a valid JSON array of telemetry logs",
		})
		return
	}

	if len(logs) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "Zero records uploaded",
		})
		return
	}

	// Set MAC address for all records in the batch
	for i := range logs {
		logs[i].MACAddress = macAddress
	}

	// Batch insert into Database (Chunk size = 100 entries per insert statement)
	result := database.DB.CreateInBatches(logs, 100)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to write logs to persistence database: " + result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": fmt.Sprintf("Successfully synchronized %d log entries for device %s", len(logs), macAddress),
	})
}
```

#### Live Logs Handler (`internal/handlers/live.go`)

Returns all logs with a local check-in (`created_at` timestamp) within the lookback window. Designed to support polling of 20 seconds.

```go
package handlers

import (
	"net/http"
	"strconv"
	"time"
	"speedcheck-backend/internal/database"
	"speedcheck-backend/internal/models"

	"github.com/gin-gonic/gin"
)

// LiveLogsHandler queries logs generated recently
func LiveLogsHandler(c *gin.Context) {
	// Lookback seconds (Default: 20s)
	secondsStr := c.DefaultQuery("seconds", "20")
	seconds, err := strconv.Atoi(secondsStr)
	if err != nil || seconds <= 0 {
		seconds = 20
	}

	// Limit count (Default: 100)
	limitStr := c.DefaultQuery("limit", "100")
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 {
		limit = 100
	}

	// Compute start lookback range
	startTime := time.Now().Add(-time.Duration(seconds) * time.Second)

	var logs []models.TelemetryLog
	result := database.DB.
		Where("created_at >= ?", startTime).
		Order("created_at DESC").
		Limit(limit).
		Find(&logs)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to query live logs: " + result.Error.Error(),
		})
		return
	}

	// Returns array directly to facilitate parsing
	c.JSON(http.StatusOK, logs)
}
```

#### History Handler (`internal/handlers/history.go`)

Returns telemetry history for a specific MAC address with support for range filtering.

```go
package handlers

import (
	"net/http"
	"strconv"
	"time"
	"speedcheck-backend/internal/database"
	"speedcheck-backend/internal/models"

	"github.com/gin-gonic/gin"
)

// GetHistoryHandler returns log history filtered by Device MAC Address
func GetHistoryHandler(c *gin.Context) {
	macAddress := c.Query("mac_address")
	if macAddress == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "mac_address query parameter is required",
		})
		return
	}

	// Pagination parameters
	limitStr := c.DefaultQuery("limit", "50")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 {
		limit = 50
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil || offset < 0 {
		offset = 0
	}

	// GORM Query builder
	query := database.DB.Model(&models.TelemetryLog{}).Where("mac_address = ?", macAddress)

	// Range filter parameters
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	if startDateStr != "" {
		if t, err := time.Parse(time.RFC3339, startDateStr); err == nil {
			query = query.Where("timestamp >= ?", t)
		}
	}
	if endDateStr != "" {
		if t, err := time.Parse(time.RFC3339, endDateStr); err == nil {
			query = query.Where("timestamp <= ?", t)
		}
	}

	// Count total matching logs
	var totalCount int64
	if err := query.Count(&totalCount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to query log count: " + err.Error(),
		})
		return
	}

	// Fetch page slice
	var logs []models.TelemetryLog
	err = query.Order("timestamp DESC").
		Limit(limit).
		Offset(offset).
		Find(&logs).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to query log history: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"mac_address": macAddress,
		"total_count": totalCount,
		"limit":       limit,
		"offset":      offset,
		"logs":        logs,
	})
}
```

#### Entry Point Router (`cmd/api/main.go`)

```go
package main

import (
	"os"
	"speedcheck-backend/internal/database"
	"speedcheck-backend/internal/handlers"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize Database Connection
	// Format: "host=localhost user=postgres password=secret dbname=speedcheck port=5432 sslmode=disable"
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=localhost user=postgres password=postgres dbname=speedcheck port=5432 sslmode=disable"
	}
	database.InitDB(dsn)

	// Set up router
	router := gin.Default()

	// Apply Middlewares (e.g. CORS, Auth) if needed
	router.Use(gin.Recovery())

	// API Group V1
	v1 := router.Group("/api/v1")
	{
		// Sync endpoint (Handles Multipart JSON upload)
		v1.POST("/data/sync", handlers.SyncLogsHandler)
		v1.POST("/data/sync/", handlers.SyncLogsHandler) // Matches either format trailing slash

		// Live telemetry views (Poll target: 20 seconds)
		v1.GET("/logs/live", handlers.LiveLogsHandler)

		// Device historical logs
		v1.GET("/history", handlers.GetHistoryHandler)
	}

	// Listen and serve
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	err := router.Run(":" + port)
	if err != nil {
		panic("Failed to run HTTP server: " + err.Error())
	}
}
```

---

## 5. Development Guidelines & Best Practices

1. **Security & Authentication**:
   - Telemetry data contains physical coordinates (`latitude` and `longitude`). Ensure transport encryption (`HTTPS/TLS`) is enforced.
   - Implement simple API token authentication via an `Authorization: Bearer <token>` header to prevent unsolicited spamming of logs database.

2. **Mobile Device Limitation Notice (MAC Address)**:
   - Modern mobile platforms (Android 10+ and iOS 11+) restrict access to hardware MAC addresses (`02:00:00:00:00:00` is returned by default for safety/privacy).
   - *Recommendation*: The Flutter app client should generate a unique installation UUID (e.g. using `uuid` package) and cache it. Use this UUID as the identifier in the `X-Device-Mac` header to maintain device affinity safely.

3. **Concurrency and Scaling**:
   - The sync endpoint uses bulk inserting via GORM's `CreateInBatches` which leverages SQL multi-row inserting. This reduces round-trips to the DB.
   - Ensure the server runs with proper pool limits (e.g. SQL connection limits `SetMaxOpenConns`).
