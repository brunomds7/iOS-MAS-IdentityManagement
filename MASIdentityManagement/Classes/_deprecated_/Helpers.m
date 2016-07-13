//
//  Helpers.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "Helpers.h"

@implementation Helpers

#pragma mark - Utility methods

+ (NSDictionary *)paramsForSearchQuery:(NSString *)query range:(NSRange)pageRange
{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (query) {
        
        [dictionary setObject:[NSString stringWithFormat:@"%@",query] forKey:@"filter"];
    }
    
    if (pageRange.location != NSNotFound) {
        
        [dictionary setObject:[NSString stringWithFormat:@"%lu", (unsigned long)pageRange.location] forKey:@"startIndex"];
        [dictionary setObject:[NSString stringWithFormat:@"%lu", (unsigned long)pageRange.length] forKey:@"count"];
    }
    
    return dictionary;
}

@end
