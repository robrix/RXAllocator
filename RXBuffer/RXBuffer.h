//  RXBuffer.h
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXBuffer : NSObject

-(void *)allocate:(size_t)size; // size must be <= kRXBufferPageSize
// fixme: that restriction can be removed by allocating a page with a specific size

-(void)free:(void *)allocation;

@end