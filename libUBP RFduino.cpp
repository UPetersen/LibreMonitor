//
// libUBP.cpp 
// C++ code
// ----------------------------------
// Developed with embedXcode+ 
// http://embedXcode.weebly.com
//
// Project 		BM019 Inventory
//
// Created by 	Uwe Petersen, 02.01.16 14:13
// 				Uwe Petersen
//
// Copyright 	(c) Uwe Petersen, 2016
// Licence		<#license#>
//
// See 			libUBP.h and ReadMe.txt for references
//


// Core library for code-sense - IDE-based
#if defined(WIRING) // Wiring specific
#   include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
#   include "WProgram.h"
#elif defined(ROBOTIS) // Robotis specific
#   include "libpandora_types.h"
#   include "pandora.h"
#elif defined(MPIDE) // chipKIT specific
#   include "WProgram.h"
#elif defined(DIGISPARK) // Digispark specific
#   include "Arduino.h"
#elif defined(ENERGIA) // LaunchPad specific
#   include "Energia.h"
#elif defined(LITTLEROBOTFRIENDS) // LittleRobotFriends specific
#   include "LRF.h"
#elif defined(MICRODUINO) // Microduino specific
#   include "Arduino.h"
#elif defined(TEENSYDUINO) // Teensy specific
#   include "Arduino.h"
#elif defined(REDBEARLAB) // RedBearLab specific
#   include "Arduino.h"
#elif defined(RFDUINO) // RFduino specific
#   include "Arduino.h"
#elif defined(SPARK) // Spark specific
#   include "application.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
#   include "Arduino.h"
#else // error
#   error Platform not defined
#endif // end IDE

// Code
//#define SIMBLEE


#include "libUBP.h"
#include <Arduino.h>
#include "crc8.h"

// Choose Simblee or RFduino
#ifdef SIMBLEE
#include <SimbleeBLE.h>
#else
#include <RFduinoBLE.h>
#endif

// Build-time configurations
//#define BUFFER_LENGTH 64
//#define BUFFER_LENGTH 64 // Uwi changed this on 2016-01-04
//#define BUFFER_LENGTH 400 // Uwi changed this on 2016-07-24
#define BUFFER_LENGTH 430 // Uwi changed this on 2016-08-07
#define TX_CHUNK_SIZE 20
#define PACKET_ID_SIZE 2

// Serial Line IP (SLIP) escaping constants
#define ESCAPE_BYTE 0xDB
#define END_BYTE    0xC0
#define ESCAPED_ESCAPE_BYTE 0xDD
#define ESCAPED_END_BYTE    0xDC
const char escapeSequence[1] = {ESCAPE_BYTE};
const char endSequence[1] = {END_BYTE};
const char escapedEndSequence[2] = {ESCAPE_BYTE, ESCAPED_END_BYTE};
const char escapedEscapeSequence[2] = {ESCAPE_BYTE, ESCAPED_ESCAPE_BYTE};

// Buffers
char ubpTxBuffer[BUFFER_LENGTH];
int ubpTxBufferLength = 0;
int ubpTxBufferSentByteCount = 0;
char ubpRxBuffer[BUFFER_LENGTH];
int ubpRxBufferLength = 0;
char ubpUnescapedRxBufferBuffer[BUFFER_LENGTH];
int ubpUnescapedRxBufferBufferLength = 0;

// State Variables
bool UBP_isTxPending = false;
bool hostIsConnected = false;

// Functions
bool UBP_isBusy() {
    
    return UBP_isTxPending;
}

void UBP_pump() {
    
    _UBP_pumpTxQueue();
}

void _UBP_pumpTxQueue() {
    
    if (UBP_isTxPending) {
        
        char *nextByteToSend = ubpTxBuffer + ubpTxBufferSentByteCount;
        
        // Try sending the next chunk
        if (ubpTxBufferSentByteCount < ubpTxBufferLength && hostIsConnected) {  // Haven't already sent all the bytes
            
            int retryRemainingCount = 1000;  // Limit the number of times we retry sending to avoid getting into an infinite loop
            int remainingByteCount = ubpTxBufferLength - ubpTxBufferSentByteCount;
            
            if (remainingByteCount >= TX_CHUNK_SIZE) {  // Can fill the TX output buffer
                
#ifdef SIMBLEE
                // Send is queued (the ble stack delays send to the start of the next tx window)
                while ( SimbleeBLE.send(nextByteToSend, TX_CHUNK_SIZE) == false && hostIsConnected && retryRemainingCount > 0) {
#else
                while ( RFduinoBLE.send(nextByteToSend, TX_CHUNK_SIZE) == false && hostIsConnected && retryRemainingCount > 0) {
#endif
                    retryRemainingCount--;
                };  // send() returns false if all tx buffers in use (can't enqueue, try again later)
                
//                delay(20); // 2016-07-12: try to get fewer transfer errors using a small delay
#ifdef DEBUG
                Serial.printf("Sending the bytes\n");
#endif
                ubpTxBufferSentByteCount += TX_CHUNK_SIZE;
                
            } else {  // Only partial TX buffer remaining to send
                
                // Send is queued (the ble stack delays send to the start of the next tx window)
#ifdef SIMBLEE
                while ( SimbleeBLE.send(nextByteToSend, remainingByteCount) == false && hostIsConnected && retryRemainingCount > 0) {#
#else
                while ( RFduinoBLE.send(nextByteToSend, remainingByteCount) == false && hostIsConnected && retryRemainingCount > 0) {
#endif
                    retryRemainingCount--;
                };  // send() returns false if all tx buffers in use (can't enqueue, try again later)
                
                ubpTxBufferSentByteCount += remainingByteCount;

//                delay(20); // 2016-07-12: try to get fewer transfer errors using a small delay
#ifdef DEBUG
                Serial.printf("Sending the remaining bytes\n");
#endif
                UBP_isTxPending = false;
            }
        }
    }
}

void _UBP_ingestRxBytes(char *receivedBytes, int byteCount) {
    
    Serial.print(byteCount);
    Serial.println(" bytes receieved");
    
    // NOTE: Assuming not called unless len > 0
    
    // Determine what to do with incoming fragment
    if ( *receivedBytes == END_BYTE ) {  // Fragment has leading END byte, signals start of packet
        
        // Set fragment as the beginning of the reconstruction buffer
        memcpy(ubpRxBuffer, receivedBytes, byteCount);
        ubpRxBufferLength = byteCount;
        
    } else if (ubpRxBufferLength > 0) {  // Already have fragments in the reconstruction buffer
        
        // Append fragment to reconstruction buffer
        memcpy(ubpRxBuffer + ubpRxBufferLength, receivedBytes, byteCount);
        ubpRxBufferLength += byteCount;
        
    }
    
    
    // Check RX buffer for trailing END byte
    if ( *(ubpRxBuffer + ubpRxBufferLength - 1) == END_BYTE) {  // RX buffer ends with END byte, looks like packet is complete
        
        byte firstNonControlIndex = 1;
        byte escapedDataLength = ubpRxBufferLength - 2;  // "- 2" for leading/trailing control chars
        
        // Un-escape the incoming payload
        ubpUnescapedRxBufferBufferLength = _UBP_makeUnEscapedCopy(ubpRxBuffer + firstNonControlIndex, escapedDataLength, ubpUnescapedRxBufferBuffer);
        byte payloadDataLength = ubpUnescapedRxBufferBufferLength - 1;  // -1 to account for checksum
        
        // Calculate checksum over payload, i.e. all bytes except for last checksum byte)
        char calculatedChecksum = CRC8(ubpUnescapedRxBufferBuffer, payloadDataLength * sizeof(byte));
        
        // Extract embedded checksum value
        char receivedChecksum = *(ubpUnescapedRxBufferBuffer + payloadDataLength);  // NOTE: Omitting '-1' because checksum byte comes just after payloadDataLength
        
        // Verify the checksum
        if (calculatedChecksum == receivedChecksum) {
            
            unsigned short packetIdentifier = *(ubpUnescapedRxBufferBuffer);
            UBP_TxFlags txFlags = (UBP_TxFlags) *(ubpUnescapedRxBufferBuffer + PACKET_ID_SIZE);
            
            if (UBP_receivedPacket) {
                
                void *packetBuffer = (ubpUnescapedRxBufferBuffer + PACKET_ID_SIZE + 1);  // skip <identifier length> + <tx flags length>
                UBP_receivedPacket(packetIdentifier, txFlags, packetBuffer);
            }
            
        } else {
            
            Serial.println("Incoming packet checksum invalid");
            
            // Reset
            ubpRxBufferLength = 0;
            ubpUnescapedRxBufferBufferLength = 0;
            
            if (UBP_incomingChecksumFailed) {
                
                UBP_incomingChecksumFailed();
            }
        }
        
    }  // else haven't RX'd final fragment yet, keep waiting
}

bool UBP_queuePacketTransmission(unsigned short packetIdentifier, UBP_TxFlags txFlags, const char *packetBytes, unsigned short byteCount) {
    
    if (UBP_isTxPending) {  // Preexisting transmission still in progress
        
#ifdef DEBUG
        Serial.println("Could not queue packet because preexisting transmission is still in progress");
#endif
        return false;
        
    } else {  // Ready to queue a new transmission
        
        if (hostIsConnected == false) {
#ifdef DEBUG
            Serial.println("Host not connected");
#endif
            return false;
        }
        
#ifdef DEBUG
        Serial.println("ready to queue a new transmission");
#endif
        ubpTxBufferLength = 0;
        
        // Start off with the END_BYTE as required for SLIP
        ubpTxBuffer[0] = END_BYTE;
        ubpTxBufferLength++;
        
        // Prepend the packet identifier
        memcpy(ubpTxBuffer + ubpTxBufferLength, &packetIdentifier, sizeof(packetIdentifier));  // TODO: Escape the identifier
        ubpTxBufferLength += sizeof(packetIdentifier);
        
        // Append the transmission flags
        ubpTxBuffer[ubpTxBufferLength] = txFlags;
        ubpTxBufferLength++;
#ifdef DEBUG
        Serial.println("appended the transmission flags");
#endif
        
        // Copy the escaped contents of packetBytes into the TX buffer following the packet identifier
        int escapedByteCount = _UBP_makeEscapedCopy(packetBytes, byteCount, ubpTxBuffer + ubpTxBufferLength, BUFFER_LENGTH);
#ifdef DEBUG
        Serial.println("made escaped copy");
#endif
        
        if (escapedByteCount != -1) {  // Escaping succeeded
            
            ubpTxBufferLength += escapedByteCount;
            int payloadLength = ubpTxBufferLength - 1;  // Length so far minus leading END byte    //sizeof(packetIdentifier) + escapedByteCount;  // <identifier length> + <escaped content length>
            
            // Calculate and append checksum
            byte checksumValue = CRC8(ubpTxBuffer + 1, payloadLength);  // Checksum over all payload bytes (minus the leading END byte, checksum, and trailing END byte)
            *(ubpTxBuffer + ubpTxBufferLength) = checksumValue;
            ubpTxBufferLength++;
            
            // Append trailing END byte
            *(ubpTxBuffer + ubpTxBufferLength) = END_BYTE;
            ubpTxBufferLength++;
            
            // Mark as ready to begin transmission
            ubpTxBufferSentByteCount = 0;
            UBP_isTxPending = true;
            
        } else {
            
#ifdef DEBUG
            Serial.println("Couldn't escape the content because it was going to overflow the output buffer");
#endif
            return false;  // Return false if we couldn't escape the content because it was going to overflow the output buffer
        }
    }
}

int _UBP_makeEscapedCopy(const char *inputBuffer, unsigned short inputBufferLength, char *outputBuffer, unsigned short outputBufferLength) {
    
    unsigned int bytesCopied = 0;
    const char *inputBytes = inputBuffer;  // Cast here to avoid compiler warnings later
    
    // 2016-07-24: changed i from char to int to avoid buffer over flow that had happend for more numbers larger than 256
    //for (char i = 0; i < inputBufferLength; i++) {  // For each byte to append
    for (int i = 0; i < inputBufferLength; i++) {  // For each byte to append
        
#ifdef DEBUG
        Serial.printf("Input Buffer length is %d and i = %d\n", inputBufferLength, i);
#endif
        // Escape any control characters. Refer to Serial Line IP (SLIP) spec.
        char aByte = *(inputBytes + i);
        if (aByte == ESCAPE_BYTE) {  // Escape an ESCAPE_BYTE
            
#ifdef DEBUG
            Serial.printf("%d:%x ESC\n", bytesCopied, aByte);
#endif
            if (bytesCopied + 1 >= outputBufferLength) return -1;  // Would overflow destination buffer
            else {
                *(outputBuffer + bytesCopied++) = ESCAPE_BYTE;  // Write ESCAPE_BYTE to buffer and increment offset
                *(outputBuffer + bytesCopied++) = ESCAPED_ESCAPE_BYTE;  // Write escaped ESCAPE_BYTE to buffer and increment offset
            }
            
        } else if (aByte == END_BYTE) {  // Escape an END_BYTE
            
#ifdef DEBUG
            Serial.printf("%d:%x END\n", bytesCopied, aByte);
#endif
            if (bytesCopied + 1 >= outputBufferLength) return -1;  // Would overflow destination buffer
            else {
                *(outputBuffer + bytesCopied++) = ESCAPE_BYTE;  // Write ESCAPE_BYTE to buffer and increment offset
                *(outputBuffer + bytesCopied++) = ESCAPED_END_BYTE;  // Write escaped END_BYTE to buffer and increment offset
            }
            
        } else {  // Not a control character
            
#ifdef DEBUG
            Serial.printf("%d:%x\n", bytesCopied, aByte);
#endif
            if (bytesCopied >= outputBufferLength) return -1;  // Would overflow destination buffer
            else *(outputBuffer + bytesCopied++) = aByte;  // Copy the unmolested byte to the buffer and increment offset
        }
    }
    
    return bytesCopied;
}

int _UBP_makeUnEscapedCopy(const char *inputBuffer, unsigned short inputBufferLength, char *outputBuffer) {
    
    bool done = false;
    char * destinationBufferPtr = outputBuffer;
    const char * sourceBufferPtr = inputBuffer;
    
    // UNESCAPE END SEQUENCE
    while (!done && (sourceBufferPtr - inputBuffer) < inputBufferLength) {
        
        char * substringPtr = strstr(sourceBufferPtr, escapedEndSequence);
        if (substringPtr == NULL) done = true;
        else {
            
            // Copy bytes between last-copied byte and next escape byte
            char lengthToCopy = substringPtr - sourceBufferPtr;  // How many bytes between last byte copied and next escape byte
            memcpy(destinationBufferPtr, sourceBufferPtr, lengthToCopy);
            destinationBufferPtr += lengthToCopy;
            sourceBufferPtr += lengthToCopy;
            
            // Replace escaped source sequence with unescaped version during copy, increment pointer
            memcpy(destinationBufferPtr, endSequence, sizeof(endSequence));
            destinationBufferPtr += sizeof(endSequence);
            
            // Increment pointer past escaped end sequence
            sourceBufferPtr += sizeof(escapedEndSequence);
        }
    }
    
    // UNESCAPE ESCAPE SEQUENCE
    done = false;
    while (!done && (sourceBufferPtr - inputBuffer) < inputBufferLength) {
        
        char * substringPtr = strstr(sourceBufferPtr, escapedEscapeSequence);
        if (substringPtr == NULL) done = true;
        else {
            
            // Copy bytes between last-copied byte and next escape byte
            char lengthToCopy = substringPtr - sourceBufferPtr;  // How many bytes between last byte copied and next escape byte
            memcpy(destinationBufferPtr, sourceBufferPtr, lengthToCopy);
            destinationBufferPtr += lengthToCopy;
            sourceBufferPtr += lengthToCopy;
            
            // Replace escaped source sequence with unescaped version during copy, increment pointer
            memcpy(destinationBufferPtr, escapeSequence, sizeof(escapeSequence));
            destinationBufferPtr += sizeof(escapeSequence);
            
            // Increment pointer past escaped end sequence
            sourceBufferPtr += sizeof(escapedEscapeSequence);
        }
    }
    
    // COPY ANY TRAILING BYTES
    char lengthToCopy = (inputBuffer + inputBufferLength) - sourceBufferPtr;  // How many bytes remain to be copied
    memcpy(destinationBufferPtr, sourceBufferPtr, lengthToCopy);
    destinationBufferPtr += lengthToCopy;
    sourceBufferPtr += lengthToCopy;
    
    return (destinationBufferPtr - outputBuffer);  // Return the total number of bytes copied to the destination buffer
}

void _UBP_hostDisconnected() {
    
    hostIsConnected = false;
    
    // Reset TX subsystem
    UBP_isTxPending = false;
    
    // Reset RX subsystem
    ubpRxBufferLength = 0;
    
    // Invoke user callback
    if (UBP_didDisconnect) UBP_didDisconnect();
}


// Simblee/RFduino EVENTS
// ----------------------------------------------------
#ifdef SIMBLEE
void SimbleeBLE_onAdvertisement(bool start) {
    if (UBP_didAdvertise) UBP_didAdvertise(start);
}
void SimbleeBLE_onConnect() {
    hostIsConnected = true;
    if (UBP_didConnect) UBP_didConnect();
}
        
void SimbleeBLE_onReceive(char *data, int len) {
    _UBP_ingestRxBytes(data, len);
}
        
void SimbleeBLE_onDisconnect() {
    _UBP_hostDisconnected();
}
#else
void RFduinoBLE_onAdvertisement(bool start) {
    if (UBP_didAdvertise) UBP_didAdvertise(start);
}

void RFduinoBLE_onConnect() {
    hostIsConnected = true;
    if (UBP_didConnect) UBP_didConnect();
}

void RFduinoBLE_onReceive(char *data, int len) {
    _UBP_ingestRxBytes(data, len);
}

void RFduinoBLE_onDisconnect() {
    _UBP_hostDisconnected();
}
#endif
