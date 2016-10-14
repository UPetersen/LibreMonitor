//
//  NSData+CRC8.m
//  Bluetooth LE Test
//
//  Created by Chas Conway on 12/11/13.
//  Copyright (c) 2013 Chas Conway. All rights reserved.
//

#import "NSData+CRC8.h"

#define CRC8INIT  0x00
#define CRC8POLY  0x18              //0X18 = X^8+X^5+X^4+X^0

@implementation NSData (CRC8)

- (signed char)CRC8Checksum {
	
	signed char *buffer = malloc(self.length);
	[self getBytes:buffer length:self.length];
	return [NSData CRC8ChecksumFromBuffer:buffer bytesToRead:self.length];
}

+ (signed char)CRC8ChecksumFromBuffer:(signed char *)dataBuffer bytesToRead:(signed char)bytesToRead {
	
    signed char  crc;
    uint16_t loop_count;
    signed char  bit_counter;
    signed char  data;
    signed char  feedback_bit;
    
    crc = CRC8INIT;
    
    for (loop_count = 0; loop_count != bytesToRead; loop_count++)
    {
        data = dataBuffer[loop_count];
        
        bit_counter = 8;
        do {
            feedback_bit = (crc ^ data) & 0x01;
            
            if ( feedback_bit == 0x01 ) {
                crc = crc ^ CRC8POLY;
            }
            crc = (crc >> 1) & 0x7F;
            if ( feedback_bit == 0x01 ) {
                crc = crc | 0x80;
            }
            
            data = data >> 1;
            bit_counter--;
            
        } while (bit_counter > 0);
    }
    
    return crc;
}

@end
