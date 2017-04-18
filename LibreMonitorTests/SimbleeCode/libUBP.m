//
// Uwe Petersen: Modified version to test transmission part in iOS

#import "libUBP.h"
#import "crc8.h"

// Build-time configurations
//#define BUFFER_LENGTH 64 // Uwe changed this on 2016-01-04
//#define BUFFER_LENGTH 400 // Uwe changed this on 2016-07-24
#define BUFFER_LENGTH 440 // Uwe changed this on 2016-12-25
#define TX_CHUNK_SIZE 20
#define PACKET_ID_SIZE 2

// Serial Line IP (SLIP) escaping constants
#define ESCAPE_BYTE 0xDB
#define END_BYTE    0xC0
#define ESCAPED_ESCAPE_BYTE 0xDD
#define ESCAPED_END_BYTE    0xDC
const char escapeSequence_[1] = {ESCAPE_BYTE};
const char endSequence_[1] = {END_BYTE};
const char escapedEndSequence_[2] = {ESCAPE_BYTE, ESCAPED_END_BYTE};
const char escapedEscapeSequence_[2] = {ESCAPE_BYTE, ESCAPED_ESCAPE_BYTE};

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
bool hostIsConnected = true;
//bool hostIsConnected = false;

// 2016-06-27: for testing purposes simulate simblee
char simbleeBuffer[BUFFER_LENGTH];
int simbleeBufferLength = 0;

/*
// Functions
bool UBP_isBusy() {
    
    return UBP_isTxPending;
}
 */
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
                
                // Send is queued (the ble stack delays send to the start of the next tx window)
                while (hostIsConnected && retryRemainingCount > 0) {
                    retryRemainingCount--;
                };
                // 2016-06-27: This changed to the above to enable testing
                // while ( SimbleeBLE.send(nextByteToSend, TX_CHUNK_SIZE) == false && hostIsConnected && retryRemainingCount > 0) {
                //         retryRemainingCount--;
                // };  // send() returns false if all tx buffers in use (can't enqueue, try again later)
                
                ubpTxBufferSentByteCount += TX_CHUNK_SIZE;
                
            } else {  // Only partial TX buffer remaining to send
                
                // Send is queued (the ble stack delays send to the start of the next tx window)
                while ( hostIsConnected && retryRemainingCount > 0) {
                    retryRemainingCount--;
                };  // send() returns false if all tx buffers in use (can't enqueue, try again later)
                // 2016-06-27: This changed to the above to enable testing
                // while ( SimbleeBLE.send(nextByteToSend, remainingByteCount) == false && hostIsConnected && retryRemainingCount > 0) {
                //     retryRemainingCount--;
                // };  // send() returns false if all tx buffers in use (can't enqueue, try again later)
                
                ubpTxBufferSentByteCount += remainingByteCount;
                
                UBP_isTxPending = false;
            }
        }
    }
}
/*
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
*/

// only needed to retreive the data for testing
void getTxBuffer(char *txBuffer, int *txBufferLength) {
    for (int i=0; i<ubpTxBufferLength; i++) {
        txBuffer[i] = ubpTxBuffer[i];
    }
    *txBufferLength = ubpTxBufferLength;
}

bool UBP_queuePacketTransmission(unsigned short packetIdentifier, UBP_TxFlags txFlags, const char *packetBytes, unsigned short byteCount) {
    
    if (UBP_isTxPending) {  // Preexisting transmission still in progress
        
        // Serial.println("Could not queue packet because preexisting transmission is still in progress");
        return false;
        
    } else {  // Ready to queue a new transmission
        
        if (hostIsConnected == false) return ubpTxBuffer;
        
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
        
        // Copy the escaped contents of packetBytes into the TX buffer following the packet identifier
        int escapedByteCount = _UBP_makeEscapedCopy(packetBytes, byteCount, ubpTxBuffer + ubpTxBufferLength, BUFFER_LENGTH);
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
            
            return false;  // Return false if we couldn't escape the content because it was going to overflow the output buffer
        }
    }
    // 2016-06-27: this was missing in the original code
    return true;
}

int _UBP_makeEscapedCopy(const char *inputBuffer, unsigned short inputBufferLength, char *outputBuffer, unsigned short outputBufferLength) {
    
    unsigned int bytesCopied = 0;
    const char *inputBytes = inputBuffer;  // Cast here to avoid compiler warnings later
    

    // 2016-07-24: changed i from char to int to avoid buffer over flow that had happend for more numbers larger than 256
    //for (char i = 0; i < inputBufferLength; i++) {  // For each byte to append
    for (int i = 0; i < inputBufferLength; i++) {  // For each byte to append
//        printf("i = %i", (int) i);
        
        // Escape any control characters. Refer to Serial Line IP (SLIP) spec.
        char aByte = *(inputBytes + i);
        if (aByte ==  (char) ESCAPE_BYTE) {  // Escape an ESCAPE_BYTE
//      if (aByte == ESCAPE_BYTE) {  // Escape an ESCAPE_BYTE
            
            if (bytesCopied + 1 >= outputBufferLength) return -1;  // Would¥ overflow destination buffer
            else {
                *(outputBuffer + bytesCopied++) = ESCAPE_BYTE;  // Write ESCAPE_BYTE to buffer and increment offset
                *(outputBuffer + bytesCopied++) = ESCAPED_ESCAPE_BYTE;  // Write escaped ESCAPE_BYTE to buffer and increment offset
            }
            
//        } else if (aByte == END_BYTE) {  // Escape an END_BYTE
        } else if (aByte == (char) END_BYTE) {  // Escape an END_BYTE
            
            if (bytesCopied + 1 >= outputBufferLength) return -1;  // Would overflow destination buffer
            else {
                *(outputBuffer + bytesCopied++) = ESCAPE_BYTE;  // Write ESCAPE_BYTE to buffer and increment offset
                *(outputBuffer + bytesCopied++) = ESCAPED_END_BYTE;  // Write escaped END_BYTE to buffer and increment offset
            }
            
        } else {  // Not a control character
            
            if (bytesCopied >= outputBufferLength) return -1;  // Would overflow destination buffer
            else *(outputBuffer + bytesCopied++) = aByte;  // Copy the unmolested byte to the buffer and increment offset
        }
    }
    
    return bytesCopied;
}

/*

int _UBP_makeUnEscapedCopy(const char *inputBuffer, unsigned short inputBufferLength, char *outputBuffer) {
    
    bool done = false;
    char * destinationBufferPtr = outputBuffer;
    const char * sourceBufferPtr = inputBuffer;
    
    // UNESCAPE END Sequence_
    while (!done && (sourceBufferPtr - inputBuffer) < inputBufferLength) {
        
        char * substringPtr = strstr(sourceBufferPtr, escapedEndSequence_);
        if (substringPtr == NULL) done = true;
        else {
            
            // Copy bytes between last-copied byte and next escape byte
            char lengthToCopy = substringPtr - sourceBufferPtr;  // How many bytes between last byte copied and next escape byte
            memcpy(destinationBufferPtr, sourceBufferPtr, lengthToCopy);
            destinationBufferPtr += lengthToCopy;
            sourceBufferPtr += lengthToCopy;
            
            // Replace escaped source sequence with unescaped version during copy, increment pointer
            memcpy(destinationBufferPtr, endSequence_, sizeof(endSequence_));
            destinationBufferPtr += sizeof(endSequence_);
            
            // Increment pointer past escaped end Sequence_
            sourceBufferPtr += sizeof(escapedEndSequence_);
        }
    }
    
    // UNESCAPE ESCAPE SEQUENCE
    done = false;
    while (!done && (sourceBufferPtr - inputBuffer) < inputBufferLength) {
        
        char * substringPtr = strstr(sourceBufferPtr, escapedEscapeSequence_);
        if (substringPtr == NULL) done = true;
        else {
            
            // Copy bytes between last-copied byte and next escape byte
            char lengthToCopy = substringPtr - sourceBufferPtr;  // How many bytes between last byte copied and next escape byte
            memcpy(destinationBufferPtr, sourceBufferPtr, lengthToCopy);
            destinationBufferPtr += lengthToCopy;
            sourceBufferPtr += lengthToCopy;
            
            // Replace escaped source sequence with unescaped version during copy, increment pointer
            memcpy(destinationBufferPtr, escapeSequence_, sizeof(escapeSequence_));
            destinationBufferPtr += sizeof(escapeSequence_);
            
            // Increment pointer past escaped end Sequence_
            sourceBufferPtr += sizeof(escapedEscapeSequence_);
        }
    }
    
    // COPY ANY TRAILING BYTES
    char lengthToCopy = (inputBuffer + inputBufferLength) - sourceBufferPtr;  // How many bytes remain to be copied
    memcpy(destinationBufferPtr, sourceBufferPtr, lengthToCopy);
    destinationBufferPtr += lengthToCopy;
    sourceBufferPtr += lengthToCopy;
    
    return (destinationBufferPtr - outputBuffer);  // Return the total number of bytes copied to the destination buffer
}

 */

void _UBP_hostDisconnected() {
    
    hostIsConnected = false;
    
    // Reset TX subsystem
    UBP_isTxPending = false;
    
    // Reset RX subsystem
    ubpRxBufferLength = 0;
    
    // Invoke user callback
    // 2016-06-28: commentet out for testing
//    if (UBP_didDisconnect) UBP_didDisconnect();
}


// RFduino EVENTS
// ----------------------------------------------------
//void SimbleeBLE_onAdvertisement(bool start) {
//    
//    if (UBP_didAdvertise) UBP_didAdvertise(start);
//}
//
void SimbleeBLE_onConnect() {
    
    hostIsConnected = true;
    
    // 2016-06-29: uncommented and added for testing purposes
    // if (UBP_didConnect) UBP_didConnect();
    UBP_isTxPending = false;
}

//void SimbleeBLE_onReceive(char *data, int len) {
//    
//    _UBP_ingestRxBytes(data, len);
//}

void SimbleeBLE_onDisconnect() {
    
    _UBP_hostDisconnected();
}


