//  RXBuffer.h
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/**
 A buffer allocator which is optimized for small allocations (< 1KB) and freeing/reallocating the most recent allocation it has made.
 */

@interface RXBuffer : NSObject

// size must be <= kRXBufferPageSize
-(void *)allocate:(size_t)size;
// fixme: that restriction can be removed by allocating a page with a specific size

-(void)free:(void *)allocation;

// toSize must be <= kRXBufferPageSize
// copies if the allocation is not the latest allocation on its page
// copies if the allocation would become larger than the page
-(void *)reallocate:(void *)allocation fromSize:(size_t)fromSize toSize:(size_t)toSize;

@end