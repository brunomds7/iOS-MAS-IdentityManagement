//
//  Helpers.h
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

@interface Helpers : NSObject

+ (NSDictionary *)paramsForSearchQuery:(NSString *)query range:(NSRange)pageRange;

@end
