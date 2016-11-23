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
    
    self.objectId       = [attributes valueForKey:MASIdMgmtGroupAttributeId];
    self.groupName      = [attributes valueForKey:MASIdMgmtGroupAttributeDisplayName];
    self.owner          = [[attributes valueForKey:MASIdMgmtGroupAttributeOwner] valueForKey:MASIdMgmtValue];
    self.members        = [attributes valueForKey:MASIdMgmtGroupAttributeMembers];
    
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)objectId
{
    return objc_getAssociatedObject(self, &MASIdMgmtGroupAttributeId);
}

- (void)setObjectId:(NSString *)objectId
{
    objc_setAssociatedObject(self, &MASIdMgmtGroupAttributeId, objectId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)groupName
{
    return objc_getAssociatedObject(self, &MASIdMgmtGroupAttributeDisplayName);
}

- (void)setGroupName:(NSString *)groupName
{
    objc_setAssociatedObject(self, &MASIdMgmtGroupAttributeDisplayName, groupName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)owner
{
    return objc_getAssociatedObject(self, &MASIdMgmtGroupAttributeOwner);
}

- (void)setOwner:(NSString *)owner
{
    objc_setAssociatedObject(self, &MASIdMgmtGroupAttributeOwner, owner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSArray *)members
{
    return objc_getAssociatedObject(self, &MASIdMgmtGroupAttributeMembers);
}

- (void)setMembers:(NSArray *)members
{
    objc_setAssociatedObject(self, &MASIdMgmtGroupAttributeMembers, members, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


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
    
    group.objectId      = self.objectId;
    group.groupName     = self.groupName;
    group.owner         = self.owner;
    group.members       = self.members;
    
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
