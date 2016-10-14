//
//  NSData+SLIP.h
//  Arduino Greenhouse
//
//  Created by Chas Conway on 5/23/14.
//  Copyright (c) 2014 Chas Conway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SLIP)

- (NSIndexSet *)indexesOfEndBytes;
- (NSData *)unescapedData;

- (BOOL)beginsWithEndByte;
- (BOOL)endsWithEndByte;

@end
