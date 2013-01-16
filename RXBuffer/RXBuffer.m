//  RXBuffer.m
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXBuffer.h"
#import "RXBufferPage.h"

@interface RXBuffer ()

@property (nonatomic, assign) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableArray *pages;

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


#pragma mark Synchronized; call off the queue

-(void *)allocate:(size_t)size {
	NSParameterAssert(size <= kRXBufferPageSize);
	
	__block void *allocation = NULL;
	dispatch_sync(self.queue, ^{
		RXBufferPage *page =
			[self bestFittingPageForAllocationOfSize:size]
		?:	[self addEmptyPage];
		
		allocation = [page allocate:size];
	});
	return allocation;
}


#pragma mark Unsynchronized; call on the queue

-(RXBufferPage *)bestFittingPageForAllocationOfSize:(size_t)size {
	RXBufferPage *page = nil;
	for (RXBufferPage *each in self.pages) {
		if (each.freeLength >= size) {
			if (each.allocatedLength > page.allocatedLength)
				page = each;
		}
	}
	return page;
}

-(RXBufferPage *)addEmptyPage {
	RXBufferPage *page = [RXBufferPage new];
	[self.pages addObject:page];
	return page;
}

@end


