//
//  NSData+SLIP.m
//  Arduino Greenhouse
//
//  Created by Chas Conway on 5/23/14.
//  Copyright (c) 2014 Chas Conway. All rights reserved.
//
//  Modified by Uwe Petersen

#import "NSData+SLIP.h"

// Serial Line IP (SLIP) escaping constants
#define ESCAPE_BYTE 0xDB
#define END_BYTE    0xC0
#define ESCAPED_ESCAPE_BYTE 0xDD
#define ESCAPED_END_BYTE    0xDC
const uint8_t escapeSequence[1] = {ESCAPE_BYTE};
const uint8_t endSequence[1] = {END_BYTE};
const uint8_t escapedEndSequence[2] = {ESCAPE_BYTE, ESCAPED_END_BYTE};
const uint8_t escapedEscapeSequence[2] = {ESCAPE_BYTE, ESCAPED_ESCAPE_BYTE};

@implementation NSData (SLIP)

- (NSIndexSet *)indexesOfEndBytes {
	
	__block NSMutableIndexSet *endByteIndices = [NSMutableIndexSet new];
	
	[self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
		
		for (NSInteger i = byteRange.location; i < (byteRange.location + byteRange.length); i++) {  // For each byte in the range
			
			uint8_t aByte = *((uint8_t *)bytes + i);
			if (aByte == END_BYTE) [endByteIndices addIndex:i];
		}
	}];
	
	return endByteIndices;
}

- (NSData *)unescapedData {
	

    
	NSMutableData *outputData = [[NSMutableData alloc] initWithData:self];

	BOOL done = NO;
    NSUInteger notYetUnescaped = 0; // 2016-06-30, Uwe Petersen:
	while (!done) {  // Search for escaped END bytes
	
        // 2016-06-30, Uwe Petersen:
        NSRange resultRange = [outputData rangeOfData:[NSData dataWithBytes:escapedEndSequence length:2] options:0 range:NSMakeRange(notYetUnescaped, outputData.length - notYetUnescaped)];
//        NSRange resultRange = [outputData rangeOfData:[NSData dataWithBytes:escapedEndSequence length:2] options:0 range:NSMakeRange(0, outputData.length)];
		if (resultRange.location != NSNotFound) {  // Found an occurance
			
			// Replace that escaped occurance with the unescaped value
			[outputData replaceBytesInRange:resultRange withBytes:endSequence length:1];
            notYetUnescaped = resultRange.location + 1; // 2016-06-30, Uwe Petersen
		
		} else {  // Didn't find any more occurances, so exit while loop
			
			done = YES;
		}
	}
	
	done = NO;
    notYetUnescaped = 0; // 2016-06-30, Uwe Petersen
	while (!done) {  // Search for escaped ESCAPE bytes
		
        // 2016-06-30, Uwe Petersen:
        NSRange resultRange = [outputData rangeOfData:[NSData dataWithBytes:escapedEscapeSequence length:2] options:0 range:NSMakeRange(notYetUnescaped, outputData.length - notYetUnescaped)];
//        NSRange resultRange = [outputData rangeOfData:[NSData dataWithBytes:escapedEscapeSequence length:2] options:0 range:NSMakeRange(0, outputData.length)];
		if (resultRange.location != NSNotFound) {  // Found an occurance
			
			// Replace that escaped occurance with the unescaped value
			[outputData replaceBytesInRange:resultRange withBytes:escapeSequence length:1];
            notYetUnescaped = resultRange.location + 1; // 2016-06-30, Uwe Petersen

			
		} else {  // Didn't find any more occurances, so exit while loop
			
			done = YES;
		}
	}
	
	return [NSData dataWithData:outputData];
}

- (BOOL)beginsWithEndByte {
	
	NSIndexSet *endByteIndices = [self indexesOfEndBytes];
	return [endByteIndices containsIndex:0];
}

- (BOOL)endsWithEndByte {
	
	NSIndexSet *endByteIndices = [self indexesOfEndBytes];
	return [endByteIndices containsIndex:(self.length - 1)];
}

@end
