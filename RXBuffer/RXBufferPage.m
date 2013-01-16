//  RXBufferPage.m
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXBufferPage.h"

#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC due to its reliance on class_createInstance and object_getIndexedIvars.
#endif

const size_t kRXBufferPageSize = 4096;

@interface RXBufferPage ()

@property (nonatomic, assign, readwrite) NSUInteger allocationCount;

@property (nonatomic, assign) uint8_t *latestAllocationStart;
@property (nonatomic, assign) uint8_t *latestAllocationEnd;

@end

@implementation RXBufferPage

+(instancetype)allocWithZone:(NSZone *)zone {
	return class_createInstance(self, kRXBufferPageSize);
}

-(instancetype)init {
	if ((self = [super init])) {
		_latestAllocationStart = _latestAllocationEnd = self.bytes;
	}
	return self;
}


-(uint8_t *)bytes {
	return object_getIndexedIvars(self);
}


-(void *)allocate:(size_t)size {
	NSParameterAssert(self.allocatedLength + size <= kRXBufferPageSize);
	
	self.latestAllocationStart = self.latestAllocationEnd;
	self.latestAllocationEnd += size;
	
	return self.latestAllocationStart;
}


-(NSUInteger)allocatedLength {
	return (self.latestAllocationEnd - self.bytes);
}

-(NSUInteger)freeLength {
	return kRXBufferPageSize - self.allocatedLength;
}

@end
