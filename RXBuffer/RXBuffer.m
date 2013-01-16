//  RXBuffer.m
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXBuffer.h"
#import "RXBufferPage.h"

const size_t kRXBufferPageSize = 4096;

@interface RXBuffer ()

@property (nonatomic, assign) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) RXBufferPage *emptyPage;

@end

@implementation RXBuffer

-(instancetype)init {
	if ((self = [super init])) {
		_pages = [NSMutableArray new];
		_queue = dispatch_queue_create("com.antitypical.RXBuffer", 0);
	}
	return self;
}

-(void)dealloc {
	dispatch_release(_queue);
}


#pragma mark Public; synchronized; call off the queue

-(void *)allocate:(size_t)size {
	__block void *allocation = NULL;
	dispatch_sync(self.queue, ^{
		allocation = [self allocateFromQueue:size];
	});
	return allocation;
}

-(void)free:(void *)allocation {
	__block bool freedAllocationWasAllocatedOnOwnedPage = NO;
	dispatch_sync(self.queue, ^{
		freedAllocationWasAllocatedOnOwnedPage = [self freeFromQueue:allocation];
	});
	NSParameterAssert(freedAllocationWasAllocatedOnOwnedPage);
}

-(void *)reallocate:(void *)allocation fromSize:(size_t)fromSize toSize:(size_t)toSize {
	__block void *reallocation = NULL;
	__block bool reallocatedAllocationWasAllocatedOnOwnedPage = NO;
	dispatch_sync(self.queue, ^{
		RXBufferPage *page = [self pageContainingAllocation:allocation];
		if ([page canReallocateAllocationInPlace:allocation fromSize:fromSize toSize:toSize]) {
			reallocation = [page reallocateInPlace:allocation fromSize:fromSize toSize:toSize];
		} else {
			reallocation = [self allocateFromQueue:toSize];
			memcpy(reallocation, allocation, fromSize);
			[self freeFromQueue:allocation onPage:page];
		}
		reallocatedAllocationWasAllocatedOnOwnedPage = (page != nil);
	});
	NSParameterAssert(reallocatedAllocationWasAllocatedOnOwnedPage);
	return reallocation;
}


#pragma mark Private; unsynchronized; call on the queue

-(void *)allocateFromQueue:(size_t)size {
	RXBufferPage *page =
		[self bestFittingPageForAllocationOfSize:size]
	?:	[self addEmptyPageOfSize:size];
	
	return [page allocate:size];
}

-(void)freeFromQueue:(void *)allocation onPage:(RXBufferPage *)page {
	[page free:allocation];
	if (page.allocationCount == 0) {
		if (self.emptyPage) {
			[self.pages removeObject:page];
		} else {
			[page reset];
			self.emptyPage = page;
		}
	}
}

-(bool)freeFromQueue:(void *)allocation {
	RXBufferPage *page = [self pageContainingAllocation:allocation];
	[self freeFromQueue:allocation onPage:page];
	return (page != nil);
}

-(RXBufferPage *)bestFittingPageForAllocationOfSize:(size_t)size {
	RXBufferPage *page = nil;
	for (RXBufferPage *each in self.pages) {
		if ((each.freeLength >= size) && (each.allocatedLength > page.allocatedLength))
			page = each;
	}
	return page;
}

-(RXBufferPage *)pageContainingAllocation:(void *)allocation {
	RXBufferPage *page = nil;
	for (RXBufferPage *each in self.pages) {
		if ([each containsAllocation:allocation]) {
			page = each;
			break;
		}
	}
	return page;
}

// allocates a page which is a minimum of kRXBufferPageSize
-(RXBufferPage *)addEmptyPageOfSize:(size_t)size {
	RXBufferPage *page = [RXBufferPage pageOfSize:size < kRXBufferPageSize? kRXBufferPageSize : size];
	[self.pages addObject:page];
	return page;
}

@end
