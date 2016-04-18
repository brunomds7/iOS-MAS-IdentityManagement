//
//  Helpers.h
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-11-28.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helpers : NSObject

+ (NSDictionary *)paramsForSearchQuery:(NSString *)query range:(NSRange)pageRange;

@end
