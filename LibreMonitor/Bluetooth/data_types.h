// Data types for data to be transfered
// Need a struct with one variable and the packed attribute to make this an array in swift (in a simple way


// Battery
typedef struct  __attribute__((packed)) {
    float voltage;
    float temperature;
} BatteryDataType;


/// System information command response
/// @detail Contains the relevant information received with the system information command is already distributed into the follwing parameters. See the BM019 manual and the CR95HF manual for information on the the codes and flag meanings
typedef struct  __attribute__((packed)) {
    uint8_t uid[8];
    uint8_t resultCode;
    uint8_t responseFlags;
    /// infoFlags bit 0 is set to 1 in case of error
    uint8_t infoFlags;
    uint8_t errorCode;
} SystemInformationDataType;


/// IDN command response, which is the device ID
/// @detail Contains the relevant information received with the IDN command is already distributed into the follwing parameters. See the BM019 manual and the CR95HF manual for information on the the codes and flag meanings
/// @param resultCode 0x00 if no error
/// @param deiceID 13 bytes containing the device ID.
typedef struct  __attribute__((packed)) {
    uint8_t resultCode;
    uint8_t deviceID[13];
    uint8_t romCRC[2];
} IDNDataType;


/// The first 344 bytes of data as read from FRAM of the Freestyle Libre Sensor
/// @detail Contains 24 byes of header, 296 bytes of body with blood sugar data
/// and 24 bytes of footer
/// @param bytes 344 bytes containing the the raw data
typedef struct  __attribute__((packed)) {
    uint8_t allBytes[344];
} AllBytesDataType;

/// State of BM019 NFC module
typedef struct  __attribute__((packed)) {
    /// Indicates state of BM019 NFC module.
    /// @detail 0 ... NFC is not ready because ISO15693 protocol not (yet) set,
    /// @detail 1 ... NFC is ready because ISO15693 protocol is set.
    uint8_t nfcReady;
} NFCState;


/**
 @brief Complete packet of data received via bluetooth.
 
 @detail This struct contains all relevant data collected from the Freestyle Libre sensor and transmitted via bluetooth.
 */
typedef struct  __attribute__((packed)) {
    
    /// State of BM019.
    /// @detail 0 ... ISO15693 protocol not (yet) set,
    /// @detail 1 ... ISO15693 protocol is set.
    uint8_t nfcState;
    
    /// Voltage of the device.
    /// @detail  If a regulated lipo is used, the voltage may remain constant for a long time and only drop shortly before it is discharged.
    float voltage;
    
    /// Temperature of the RFduino/Simblee in degrees Celsius.
    float temperature;
    
    /// 8 bytes containing the sensor uid.
    /// @detail Sensor uid is read via System Information Comand.
    /// The order is already reversed, e.g. (colons only inserted for readability): E0:07:A0:00:00:0C:48:BD.
    uint8_t sensorUID[8];
    
    /// Result code from System Information command used to read sensor uid.
    /// @detail 0x80 if received correctly.
    uint8_t sensorUIDresultCode;

    /// Error code response from System Information command used to read sensor uid.
    /// @detail 0x00 if no error.
    uint8_t sensorUIDerrorCode;
    
    /// Device ID of the CH95RF.
    /// @detail 13 bytes containing the device ID of the CH95RF chip on the BM019 module. Read with the Identification Number (IDN) command.
    uint8_t deviceID[13];
    
    /// Result code for Identification Number (IDN) command to read device id.
    /// @detail 0x80 if no error.
    uint8_t deviceIDresultCode;
    /// FRAM of Freestyle Libre sensor.
    /// @detail The first 344 bytes of data as read from FRAM of the Freestyle Libre Sensor. Consist of three consecutive units of data, that are each secured by a crc 16. These units are:
    /// @detail 24 header byes with information about sensor state,
    /// @detail 296 body bytes with blood sugar data and minute counter and
    /// @detail 24 footer bytes, the information of which is not yet understood.
    uint8_t fram[344];
} Transmission;

