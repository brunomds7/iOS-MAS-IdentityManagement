//
//  MASUser+MASIdentityManagementPrivate.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASUser+MASIdentityManagementPrivate.h"

#import <objc/runtime.h>


static NSString *const kMASUserIsCurrentUserPropertyKey = @"isCurrentUser";


@implementation MASUser (MASIdentityManagementPrivate)


- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    self.objectId       = [attributes valueForKey:MASIdMgmtUserAttributeId];
    self.userName       = [attributes valueForKey:MASIdMgmtUserAttributeUserName];
    self.familyName     = [[attributes valueForKey:MASIdMgmtUserAttributeName] valueForKey:MASIdMgmtUserAttributeFamilyName];
    self.givenName      = [[attributes valueForKey:MASIdMgmtUserAttributeName] valueForKey:MASIdMgmtUserAttributeGivenName];
    
    //
    // Formatted Name
    //
    NSMutableString *mutableCopy = [NSMutableString new];
    
    // Given name, if any
    if(self.givenName) [mutableCopy appendString:self.givenName];
    
    // Family name, if any
    if(self.familyName)
    {
        // Check if there was a given name first, if so add a space
        if(mutableCopy.length > 0) [mutableCopy appendString:MASIdMgmtEmptySpace];
        
        [mutableCopy appendString:self.familyName];
    }
    
    if(mutableCopy.length > 0) self.formattedName = mutableCopy;

    self.emailAddresses = [attributes valueForKey:MASIdMgmtUserAttributeEmails];
    self.phoneNumbers   = [attributes valueForKey:MASIdMgmtUserAttributePhoneNumbers];
    self.addresses      = [attributes valueForKey:MASIdMgmtUserAttributeAddresses];
    self.groups         = [attributes valueForKey:MASIdMgmtUserAttributeGroups];
    
    //
    // Picture (only the first one found)
    //
    NSString *imageUriAsString = [attributes valueForKey:MASIdMgmtUserAttributePhotos];
    if(imageUriAsString)
    {
        //DLog(@"\n\nImage URI as string: %@\n\n", imageUriAsString);
        
        NSURL *imageUrl = [NSURL URLWithString:[[attributes valueForKey:MASIdMgmtUserAttributePhotos][0] objectForKey:MASIdMgmtValue]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        self.photos = @{ MASIdMgmtUserAttributeThumbnailPhoto : [UIImage imageWithData:imageData] };
    }
    
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)objectId
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeId);
}

- (void)setObjectId:(NSString *)objectId
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeId, objectId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)isCurrentUser
{
    NSNumber *isCurrentUserNumber = objc_getAssociatedObject(self, &kMASUserIsCurrentUserPropertyKey);
    
    return [isCurrentUserNumber boolValue];
}

- (void)setIsCurrentUser:(BOOL)isCurrentUser
{
    objc_setAssociatedObject(self, &kMASUserIsCurrentUserPropertyKey, [NSNumber numberWithBool:isCurrentUser], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)userName
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeUserName);
}

- (void)setUserName:(NSString *)userName
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeUserName, userName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)familyName
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeFamilyName);
}

- (void)setFamilyName:(NSString *)familyName
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeFamilyName, familyName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)givenName
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeGivenName);
}

- (void)setGivenName:(NSString *)givenName
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeGivenName, givenName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)formattedName
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeFormattedName);
}

- (void)setFormattedName:(NSString *)formattedName
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeFormattedName, formattedName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)emailAddresses
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeEmails);
}

- (void)setEmailAddresses:(NSDictionary *)emailAddresses
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeEmails, emailAddresses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)phoneNumbers
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributePhoneNumbers);
}

- (void)setPhoneNumbers:(NSDictionary *)phoneNumbers
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributePhoneNumbers, phoneNumbers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)addresses
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeAddresses);
}

- (void)setAddresses:(NSDictionary *)addresses
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeAddresses, addresses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSArray *)groups
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributeGroups);
}

- (void)setGroups:(NSArray *)groups
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeGroups, groups, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)active
{
    NSNumber *activeNumber = objc_getAssociatedObject(self, &MASIdMgmtUserAttributeActive);
    
    return [activeNumber boolValue];
}

- (void)setActive:(BOOL)active
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributeActive, [NSNumber numberWithBool:active], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)photos
{
    return objc_getAssociatedObject(self, &MASIdMgmtUserAttributePhotos);
}

- (void)setPhotos:(NSDictionary *)photos
{
    objc_setAssociatedObject(self, &MASIdMgmtUserAttributePhotos, photos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)_attributes
{
    return objc_getAssociatedObject(self, &MASIdMgmtAttributes);
}

- (void)set_attributes:(NSDictionary *)attributes
{
    objc_setAssociatedObject(self, &MASIdMgmtAttributes, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


# pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASUser *user = [[MASUser alloc] init];
    
    user.objectId       = self.objectId;
    user.userName       = self.userName;
    user.familyName     = self.familyName;
    user.givenName      = self.givenName;
    user.formattedName  = self.formattedName;
    user.emailAddresses = self.emailAddresses;
    user.phoneNumbers   = self.phoneNumbers;
    user.addresses      = self.addresses;
    user.groups         = self.groups;
    user.active         = self.active;
    user.photos         = self.photos;
    
    return user;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    if(self.isCurrentUser) [aCoder encodeBool:self.isCurrentUser forKey:kMASUserIsCurrentUserPropertyKey];

    if(self.userName) [aCoder encodeObject:self.userName forKey:MASIdMgmtUserAttributeUserName];
    if(self.familyName) [aCoder encodeObject:self.familyName forKey:MASIdMgmtUserAttributeFamilyName];
    if(self.givenName) [aCoder encodeObject:self.givenName forKey:MASIdMgmtUserAttributeGivenName];
    if(self.formattedName) [aCoder encodeObject:self.formattedName forKey:MASIdMgmtUserAttributeFormattedName];
    if(self.emailAddresses) [aCoder encodeObject:self.emailAddresses forKey:MASIdMgmtUserAttributeEmails];
    if(self.phoneNumbers) [aCoder encodeObject:self.phoneNumbers forKey:MASIdMgmtUserAttributePhoneNumbers];
    if(self.addresses) [aCoder encodeObject:self.addresses forKey:MASIdMgmtUserAttributeAddresses];
    if(self.groups) [aCoder encodeObject:self.groups forKey:MASIdMgmtUserAttributeGroups];
    if(self.active) [aCoder encodeBool:self.active forKey:MASIdMgmtUserAttributeActive];
    if(self.photos) [aCoder encodeObject:self.photos forKey:MASIdMgmtUserAttributePhotos];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.isCurrentUser = [aDecoder decodeBoolForKey:kMASUserIsCurrentUserPropertyKey];
        
        self.userName = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeUserName];
        self.familyName = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeFamilyName];
        self.givenName = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeGivenName];
        self.formattedName = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeFormattedName];
        self.photos = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributePhotos];
        self.emailAddresses = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeEmails];
        self.phoneNumbers = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributePhoneNumbers];
        self.addresses = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeAddresses];
        self.groups = [aDecoder decodeObjectForKey:MASIdMgmtUserAttributeGroups];
        self.active = [aDecoder decodeBoolForKey:MASIdMgmtUserAttributeActive];
    }
    
    return self;
}

@end
