//  RXBufferPage.m
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXBufferPage.h"

#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC due to its reliance on class_createInstance and object_getIndexedIvars.
#endif



@interface RXBufferPage ()

@property (nonatomic, assign, readwrite) NSUInteger allocationCount;

@property (nonatomic, assign) void *latestAllocationStart;
@property (nonatomic, assign) void *latestAllocationEnd;

@end

@implementation RXBufferPage

+(instancetype)pageOfSize:(size_t)size {
	RXBufferPage *page = class_createInstance(self, size);
	return [page initWithSize:size];
}

-(instancetype)initWithSize:(size_t)size {
	if ((self = [super init])) {
		_size = size;
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

-(void *)reallocateInPlace:(void *)allocation fromSize:(size_t)fromSize toSize:(size_t)toSize {
	self.latestAllocationEnd = self.latestAllocationStart + toSize;
	return self.latestAllocationStart;
}


-(void)reset {
	self.allocationCount = 0;
	self.latestAllocationEnd = self.latestAllocationEnd = self.bytes;
}


-(NSUInteger)allocatedLength {
	return (self.latestAllocationEnd - self.bytes);
}

-(NSUInteger)freeLength {
	return self.size - self.allocatedLength;
}


-(bool)containsAllocation:(void *)allocation {
	return
		(allocation >= self.bytes)
	&&	(allocation <= self.latestAllocationStart);
}

-(bool)canFitReallocationToSize:(size_t)size {
	size_t spaceForReallocation = self.latestAllocationStart - self.bytes;
	return spaceForReallocation >= size;
}

-(bool)canReallocateAllocationInPlace:(void *)allocation fromSize:(size_t)fromSize toSize:(size_t)toSize {
	bool isSmaller = toSize < fromSize;
	bool isLatest = allocation == self.latestAllocationStart;
	return
		isSmaller
	||	(isLatest && [self canFitReallocationToSize:toSize]);
}

@end
