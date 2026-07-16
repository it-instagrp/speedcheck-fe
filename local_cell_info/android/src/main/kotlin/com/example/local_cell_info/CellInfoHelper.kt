package com.example.local_cell_info

import android.content.Context
import android.os.Build
import android.telephony.*

object CellInfoHelper {
    fun getCellDetails(context: Context): Map<String, Any?> {
        val details = mutableMapOf<String, Any?>()
        try {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            var carrier = telephonyManager.networkOperatorName
            if (carrier.isNullOrEmpty()) {
                carrier = telephonyManager.simOperatorName
            }
            if (carrier.isNullOrEmpty() || carrier == "Unknown") {
                val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                if (subscriptionManager != null) {
                    try {
                        val activeSubscriptionInfoList = subscriptionManager.activeSubscriptionInfoList
                        if (activeSubscriptionInfoList != null && activeSubscriptionInfoList.isNotEmpty()) {
                            carrier = activeSubscriptionInfoList[0].carrierName?.toString()
                        }
                    } catch (e: SecurityException) {
                        // Ignore
                    }
                }
            }
            if (carrier.isNullOrEmpty()) {
                carrier = "Unknown"
            }
            details["carrierName"] = carrier

            // Collect IMEI or secure Android ID for licensing
            var imei: String? = null
            try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    @Suppress("DEPRECATION")
                    imei = telephonyManager.deviceId ?: telephonyManager.getImei(0)
                }
            } catch (e: SecurityException) {
                // Security exception
            }
            if (imei.isNullOrEmpty()) {
                imei = android.provider.Settings.Secure.getString(
                    context.contentResolver,
                    android.provider.Settings.Secure.ANDROID_ID
                )
            }
            details["imei"] = imei
            
            // Get network data connection state
            val dataState = telephonyManager.dataState
            val dataStateStr = when (dataState) {
                TelephonyManager.DATA_DISCONNECTED -> "Disconnected"
                TelephonyManager.DATA_CONNECTING -> "Connecting"
                TelephonyManager.DATA_CONNECTED -> "Connected"
                TelephonyManager.DATA_SUSPENDED -> "Suspended"
                else -> "Unknown"
            }
            details["dataState"] = dataStateStr

            // Get network technology (including SA/NSA detection)
            val networkType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                telephonyManager.dataNetworkType
            } else {
                telephonyManager.networkType
            }
            details["technology"] = getTechnologyType(telephonyManager, networkType)

            val cellInfoList = telephonyManager.allCellInfo
            val neighborsList = mutableListOf<Map<String, Any?>>()
            
            var servingMcc: String? = null
            var servingMnc: String? = null

            if (cellInfoList != null && cellInfoList.isNotEmpty()) {
                val registeredCell = cellInfoList.firstOrNull { it.isRegistered }
                
                if (registeredCell != null) {
                    details["registeredState"] = "serving"
                    
                    when (registeredCell) {
                        is CellInfoLte -> {
                            val identity = registeredCell.cellIdentity
                            val signalStrength = registeredCell.cellSignalStrength
                            
                            servingMcc = identity.mccString
                            servingMnc = identity.mncString
                            
                            details["ci"] = identity.ci.takeIf { it != Int.MAX_VALUE }
                            details["pci"] = identity.pci.takeIf { it != Int.MAX_VALUE }
                            details["tac"] = identity.tac.takeIf { it != Int.MAX_VALUE }
                            details["earfcn"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.earfcn.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            details["bandwidth"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                identity.bandwidth.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            
                            details["rsrp"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                signalStrength.rsrp.takeIf { it != Int.MAX_VALUE }
                            } else {
                                signalStrength.dbm.takeIf { it != Int.MAX_VALUE }
                            }
                            details["rsrq"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                signalStrength.rsrq.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            details["rssi"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                signalStrength.rssi.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            details["rssnr"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                signalStrength.rssnr.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            details["asuLevel"] = signalStrength.asuLevel.takeIf { it != Int.MAX_VALUE }
                            details["timingAdvance"] = signalStrength.timingAdvance.takeIf { it != Int.MAX_VALUE }
                            details["cqi"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                signalStrength.cqi.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                        }
                        is CellInfoNr -> {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                val identity = registeredCell.cellIdentity as CellIdentityNr
                                val signalStrength = registeredCell.cellSignalStrength as CellSignalStrengthNr
                                
                                servingMcc = identity.mccString
                                servingMnc = identity.mncString
                                
                                details["nci"] = identity.nci.takeIf { it != Long.MAX_VALUE && it != Int.MAX_VALUE.toLong() }
                                details["pci"] = identity.pci.takeIf { it != Int.MAX_VALUE }
                                details["tac"] = identity.tac.takeIf { it != Int.MAX_VALUE }
                                details["nrarfcn"] = identity.nrarfcn.takeIf { it != Int.MAX_VALUE }
                                
                                details["bands"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                    identity.bands.toList()
                                } else {
                                    null
                                }
                                
                                details["ssRsrp"] = signalStrength.ssRsrp.takeIf { it != CellInfo.UNAVAILABLE }
                                details["ssRsrq"] = signalStrength.ssRsrq.takeIf { it != CellInfo.UNAVAILABLE }
                                details["ssSinr"] = signalStrength.ssSinr.takeIf { it != CellInfo.UNAVAILABLE }
                                details["csiRsrp"] = signalStrength.csiRsrp.takeIf { it != CellInfo.UNAVAILABLE }
                                details["csiRsrq"] = signalStrength.csiRsrq.takeIf { it != CellInfo.UNAVAILABLE }
                                details["csiSinr"] = signalStrength.csiSinr.takeIf { it != CellInfo.UNAVAILABLE }
                                details["asuLevel"] = signalStrength.asuLevel.takeIf { it != CellInfo.UNAVAILABLE }
                                
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                    details["cqiReport"] = signalStrength.csiCqiReport
                                    details["cqiTableIndex"] = signalStrength.csiCqiTableIndex.takeIf { it != CellInfo.UNAVAILABLE }
                                }
                            }
                        }
                        is CellInfoWcdma -> {
                            val identity = registeredCell.cellIdentity
                            val signalStrength = registeredCell.cellSignalStrength
                            
                            servingMcc = identity.mccString
                            servingMnc = identity.mncString
                            
                            details["ucid"] = identity.cid.takeIf { it != Int.MAX_VALUE }
                            details["psc"] = identity.psc.takeIf { it != Int.MAX_VALUE }
                            details["lac"] = identity.lac.takeIf { it != Int.MAX_VALUE }
                            details["uarfcn"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.uarfcn.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            
                            details["rscp"] = signalStrength.dbm.takeIf { it != Int.MAX_VALUE }
                            details["ecNo"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                signalStrength.ecNo.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            details["asuLevel"] = signalStrength.asuLevel.takeIf { it != Int.MAX_VALUE }
                        }
                        is CellInfoGsm -> {
                            val identity = registeredCell.cellIdentity
                            val signalStrength = registeredCell.cellSignalStrength
                            
                            servingMcc = identity.mccString
                            servingMnc = identity.mncString
                            
                            details["cid"] = identity.cid.takeIf { it != Int.MAX_VALUE }
                            details["bsic"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.bsic.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            details["lac"] = identity.lac.takeIf { it != Int.MAX_VALUE }
                            details["arfcn"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.arfcn.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            
                            details["rssi"] = signalStrength.dbm.takeIf { it != Int.MAX_VALUE }
                            details["bitErrorRate"] = signalStrength.bitErrorRate.takeIf { it != Int.MAX_VALUE && it != 99 }
                            details["asuLevel"] = signalStrength.asuLevel.takeIf { it != Int.MAX_VALUE }
                        }
                    }
                }
                
                // Collect neighbors data
                val unregisteredCells = cellInfoList.filter { !it.isRegistered }
                for (cell in unregisteredCells) {
                    val neigh = mutableMapOf<String, Any?>()
                    when (cell) {
                        is CellInfoLte -> {
                            neigh["tech"] = "4G"
                            neigh["pci"] = cell.cellIdentity.pci.takeIf { it != Int.MAX_VALUE }
                            neigh["earfcn"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                cell.cellIdentity.earfcn.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            
                            val strength = cell.cellSignalStrength
                            neigh["rsrp"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                strength.rsrp.takeIf { it != Int.MAX_VALUE }
                            } else {
                                strength.dbm.takeIf { it != Int.MAX_VALUE }
                            }
                            neigh["rsrq"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                strength.rsrq.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                        }
                        is CellInfoNr -> {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                neigh["tech"] = "5G"
                                val identity = cell.cellIdentity as CellIdentityNr
                                val strength = cell.cellSignalStrength as CellSignalStrengthNr
                                
                                neigh["pci"] = identity.pci.takeIf { it != Int.MAX_VALUE }
                                neigh["earfcn"] = identity.nrarfcn.takeIf { it != Int.MAX_VALUE }
                                neigh["rsrp"] = strength.csiRsrp.takeIf { it != CellInfo.UNAVAILABLE }
                                neigh["rsrq"] = strength.csiRsrq.takeIf { it != CellInfo.UNAVAILABLE }
                            }
                        }
                        is CellInfoWcdma -> {
                            neigh["tech"] = "3G"
                            val identity = cell.cellIdentity
                            val strength = cell.cellSignalStrength
                            
                            neigh["psc"] = identity.psc.takeIf { it != Int.MAX_VALUE }
                            neigh["uarfcn"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.uarfcn.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            neigh["rscp"] = strength.dbm.takeIf { it != Int.MAX_VALUE }
                        }
                        is CellInfoGsm -> {
                            neigh["tech"] = "2G"
                            val identity = cell.cellIdentity
                            val strength = cell.cellSignalStrength
                            
                            neigh["bsic"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.bsic.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            neigh["arfcn"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                identity.arfcn.takeIf { it != Int.MAX_VALUE }
                            } else {
                                null
                            }
                            neigh["rxLev"] = strength.dbm.takeIf { it != Int.MAX_VALUE }
                        }
                    }
                    if (neigh.isNotEmpty()) {
                        neighborsList.add(neigh)
                    }
                }
            }
            details["neighbors"] = neighborsList
            
            // Extract MCC/MNC fallback from system operator if empty
            if (servingMcc.isNullOrEmpty() || servingMnc.isNullOrEmpty()) {
                val operator = telephonyManager.networkOperator
                if (operator != null && operator.length >= 5) {
                    servingMcc = operator.substring(0, 3)
                    servingMnc = operator.substring(3)
                }
            }
            details["mcc"] = servingMcc
            details["mnc"] = servingMnc

        } catch (e: SecurityException) {
            details["error"] = "Permission denied: ${e.message}"
        } catch (e: Exception) {
            details["error"] = e.message
        }
        return details
    }

    private fun getTechnologyType(telephonyManager: TelephonyManager, networkType: Int): String {
        if (networkType == TelephonyManager.NETWORK_TYPE_NR) {
            return "5G SA"
        }
        if (networkType == TelephonyManager.NETWORK_TYPE_LTE) {
            try {
                val serviceState = telephonyManager.serviceState
                val stateStr = serviceState?.toString() ?: ""
                if (stateStr.contains("nrState=CONNECTED") || stateStr.contains("nrState=NOT_RESTRICTED")) {
                    return "5G NSA"
                }
            } catch (e: Exception) {
                // Fail-safe
            }
        }
        return when (networkType) {
            TelephonyManager.NETWORK_TYPE_GPRS,
            TelephonyManager.NETWORK_TYPE_EDGE,
            TelephonyManager.NETWORK_TYPE_CDMA,
            TelephonyManager.NETWORK_TYPE_1xRTT,
            TelephonyManager.NETWORK_TYPE_IDEN -> "2G"
            
            TelephonyManager.NETWORK_TYPE_UMTS,
            TelephonyManager.NETWORK_TYPE_EVDO_0,
            TelephonyManager.NETWORK_TYPE_EVDO_A,
            TelephonyManager.NETWORK_TYPE_HSDPA,
            TelephonyManager.NETWORK_TYPE_HSUPA,
            TelephonyManager.NETWORK_TYPE_HSPA,
            TelephonyManager.NETWORK_TYPE_EVDO_B,
            TelephonyManager.NETWORK_TYPE_EHRPD,
            TelephonyManager.NETWORK_TYPE_HSPAP -> "3G"
            
            TelephonyManager.NETWORK_TYPE_LTE -> "4G"
            TelephonyManager.NETWORK_TYPE_NR -> "5G SA"
            else -> "Unknown"
        }
    }
}
