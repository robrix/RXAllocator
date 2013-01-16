//  RXBufferPage.h
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

extern const size_t kRXBufferPageSize;

@interface RXBufferPage : NSObject

@property (nonatomic, assign, readonly) NSUInteger allocationCount;

-(void *)allocate:(size_t)size;

@property (nonatomic, assign, readonly) NSUInteger allocatedLength;
@property (nonatomic, assign, readonly) NSUInteger freeLength;

@end
