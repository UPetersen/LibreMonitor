//
//  NSData+CRC8.h
//  Bluetooth LE Test
//
//  Created by Chas Conway on 12/11/13.
//  Copyright (c) 2013 Chas Conway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CRC8)

- (signed char)CRC8Checksum;

//+ (signed char)CRC8ChecksumFromBuffer:(signed char *)dataBuffer bytesToRead:(signed char)bytesToRead;
+ (signed char)CRC8ChecksumFromBuffer:(signed char *)dataBuffer bytesToRead:(uint16_t)bytesToRead; // changed to uint16_t by Uwi on 2016-12-26

@end
