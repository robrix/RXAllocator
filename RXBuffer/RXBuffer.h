//  RXBuffer.h
//  Created by Rob Rix on 2013-01-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/**
 The optimized size for allocations.
 */

extern const size_t kRXBufferPageSize;

/**
 A buffer allocator which is optimized for small allocations (< 1KB) and freeing/reallocating the most recent allocation it has made.
 */

@interface RXBuffer : NSObject

-(void *)allocate:(size_t)size;

-(void)free:(void *)allocation;

// copies if the allocation is not the latest allocation on its page
// copies if the allocation would become larger than the page
-(void *)reallocate:(void *)allocation fromSize:(size_t)fromSize toSize:(size_t)toSize;

@end