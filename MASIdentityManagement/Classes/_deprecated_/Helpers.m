//
//  Helpers.m
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-11-28.
//  Copyright © 2015 CA Technologies. All rights reserved.
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
