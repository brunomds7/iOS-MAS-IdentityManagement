//
//  MASGroup+MASIdentityManagementPrivate.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASGroup+MASIdentityManagementPrivate.h"

#import <objc/runtime.h>


@implementation MASGroup (MASIdentityManagementPrivate)


# pragma mark - Lifecycle

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    [self setValue:[attributes valueForKey:MASIdMgmtGroupAttributeId] forKey:@"objectId"];
    [self setValue:[attributes valueForKey:MASIdMgmtGroupAttributeDisplayName] forKey:@"groupName"];
    [self setValue:[[attributes valueForKey:MASIdMgmtGroupAttributeOwner] valueForKey:MASIdMgmtValue] forKey:@"owner"];
    [self setValue:[attributes valueForKey:MASIdMgmtGroupAttributeMembers] forKey:@"members"];
    [self setValue:[[NSMutableDictionary alloc] initWithDictionary:attributes] forKey:@"_attributes"];
    
    [self setValue:[[NSMutableDictionary alloc] initWithDictionary:attributes] forKey:@"_attributes"];
    
    return self;
}

@end
