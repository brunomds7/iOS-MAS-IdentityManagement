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
    
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSDictionary *)_attributes
{
    return objc_getAssociatedObject(self, &MASIdMgmtAttributes);
}

- (void)set_attributes:(NSDictionary *)attributes
{
    objc_setAssociatedObject(self, &MASIdMgmtAttributes, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASGroup *group = [[MASGroup alloc] init];
    
    [group setValue:self.objectId forKey:@"objectId"];
    [group setValue:self.groupName forKey:@"groupName"];
    [group setValue:self.owner forKey:@"owner"];
    [group setValue:self.members forKey:@"members"];
    
    return group;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder]; //ObjectID is encoded in the super class MASObject
    
    if(self.groupName) [aCoder encodeObject:self.groupName forKey:MASIdMgmtGroupAttributeDisplayName];
    if(self.owner) [aCoder encodeObject:self.owner forKey:MASIdMgmtGroupAttributeOwner];
    if(self.members) [aCoder encodeObject:self.members forKey:MASIdMgmtGroupAttributeMembers];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) //ObjectID is decoded in the super class MASObject
    {
        self.groupName = [aDecoder decodeObjectForKey:MASIdMgmtGroupAttributeDisplayName];
        self.owner = [aDecoder decodeObjectForKey:MASIdMgmtGroupAttributeOwner];
        self.members = [aDecoder decodeObjectForKey:MASIdMgmtGroupAttributeMembers];
    }
    
    return self;
}


@end
