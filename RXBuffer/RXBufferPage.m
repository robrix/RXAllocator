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

@property (nonatomic, assign) void *latestAllocationStart;
@property (nonatomic, assign) void *latestAllocationEnd;

@end

@implementation RXBufferPage

+(instancetype)allocWithZone:(NSZone *)zone {
	return class_createInstance(self, kRXBufferPageSize);
}

-(instancetype)init {
	if ((self = [super init])) {
		[self reset];
	}
	return self;
}


-(void *)bytes {
	return object_getIndexedIvars(self);
}


-(void *)allocate:(size_t)size {
	self.allocationCount++;
	
	self.latestAllocationStart = self.latestAllocationEnd;
	self.latestAllocationEnd += size;
	
	return self.latestAllocationStart;
}

-(void)free:(void *)allocation {
	self.allocationCount--;
	if (allocation == self.latestAllocationStart) {
		self.latestAllocationEnd = self.latestAllocationStart;
	}
}


-(void)reset {
	self.allocationCount = 0;
	self.latestAllocationEnd = self.latestAllocationEnd = self.bytes;
}


-(NSUInteger)allocatedLength {
	return (self.latestAllocationEnd - self.bytes);
}

-(NSUInteger)freeLength {
	return kRXBufferPageSize - self.allocatedLength;
}


-(bool)containsAllocation:(void *)allocation {
	return
		(allocation >= self.bytes)
	&&	(allocation <= self.latestAllocationStart);
}

@end
