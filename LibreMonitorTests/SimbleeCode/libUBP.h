/*
//
// Uwe Petersen: Modified version to test transmission part in iOS

#import <Foundation/Foundation.h>

typedef uint8_t byte;


#ifndef libUBP_h
#define libUBP_h
#endif


typedef enum {
    
    UBP_TxFlagNone = 0 << 0,
    UBP_TxFlagIsRPC = 1 << 0,
    UBP_TxFlagRequiresACK = 1 << 1
    
} UBP_TxFlags;


// Public

void UBP_pump();
bool UBP_queuePacketTransmission(unsigned short packetIdentifier, UBP_TxFlags txFlags, const char *packetBytes, unsigned short byteCount);

//bool UBP_isBusy();

// 2016-06-26: Needed for tests
void getTxBuffer(char *txBuffer, int *txBufferLength);
void SimbleeBLE_onConnect();
void SimbleeBLE_onDisconnect();




// Private

void _UBP_pumpTxQueue();

//void _UBP_ingestRxBytes(char *receivedBytes, int byteCount);

int _UBP_makeEscapedCopy(const char *inputBuffer, unsigned short inputBufferLength, char *outputBuffer, unsigned short outputBufferLength);

int _UBP_makeUnEscapedCopy(const char *inputBuffer, unsigned short inputBufferLength, char *outputBuffer);

void _UBP_hostDisconnected();


// To be implemented by end-user externally
//extern void UBP_incomingChecksumFailed() __attribute__((weak));

//extern void UBP_receivedPacket(unsigned short packetIdentifier, UBP_TxFlags txFlags, void *packetBuffer) __attribute__((weak));

//extern void UBP_didAdvertise(bool start) __attribute__((weak));

//extern void UBP_didConnect() __attribute__((weak));

//extern void UBP_didDisconnect() __attribute__((weak));
*/

