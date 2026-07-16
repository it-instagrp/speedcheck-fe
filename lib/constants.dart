// SpeedCheck Constants Configuration

// Frequency in seconds to run telemetry collect loop
const int COLLECTION_FREQUENCY_SECONDS = 10;

// API Configurations
const String API_BASE_URL = 'https://speedcheck.insagrp.com/api/v1/';
const String API_SYNC_ENDPOINT = 'data/sync/';

// Sizes for the light speed test to run every period (to keep data usage low)
// Default is 100 KB download and 50 KB upload.
const int TEST_DOWNLOAD_SIZE_BYTES = 100 * 1024;
const int TEST_UPLOAD_SIZE_BYTES = 50 * 1024;
