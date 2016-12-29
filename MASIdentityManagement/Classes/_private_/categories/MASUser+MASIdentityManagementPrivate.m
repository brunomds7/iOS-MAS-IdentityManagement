//
//  MASUser+MASIdentityManagementPrivate.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASUser+MASIdentityManagementPrivate.h"

#import <objc/runtime.h>


@implementation MASUser (MASIdentityManagementPrivate)


- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    [self setValue:[attributes valueForKey:MASIdMgmtUserAttributeId] forKey:@"objectId"];
    [self setValue:[attributes valueForKey:MASIdMgmtUserAttributeUserName] forKey:@"userName"];
    [self setValue:[[attributes valueForKey:MASIdMgmtUserAttributeName] valueForKey:MASIdMgmtUserAttributeFamilyName] forKey:@"familyName"];
    [self setValue:[[attributes valueForKey:MASIdMgmtUserAttributeName] valueForKey:MASIdMgmtUserAttributeGivenName] forKey:@"givenName"];

    
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
    
    if(mutableCopy.length > 0) [self setValue:mutableCopy forKey:@"formattedName"];

    [self setValue:[attributes valueForKey:MASIdMgmtUserAttributeEmails] forKey:@"emailAddresses"];
    [self setValue:[attributes valueForKey:MASIdMgmtUserAttributePhoneNumbers] forKey:@"phoneNumbers"];
    [self setValue:[attributes valueForKey:MASIdMgmtUserAttributeAddresses] forKey:@"addresses"];
    [self setValue:[attributes valueForKey:MASIdMgmtUserAttributeGroups] forKey:@"groups"];
    
    
    //
    // Picture (only the first one found)
    //
    NSString *imageUriAsString = [attributes valueForKey:MASIdMgmtUserAttributePhotos];
    if(imageUriAsString)
    {
        NSURL *imageUrl = [NSURL URLWithString:[[attributes valueForKey:MASIdMgmtUserAttributePhotos][0] objectForKey:MASIdMgmtValue]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        [self setValue:@{ MASIdMgmtUserAttributeThumbnailPhoto : [UIImage imageWithData:imageData] } forKey:@"photos"];
    }
    
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


# pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASUser *user = [[MASUser alloc] init];
    
    [user setValue:self.objectId forKey:@"objectId"];
    [user setValue:self.userName forKey:@"userName"];
    [user setValue:self.familyName forKey:@"familyName"];
    [user setValue:self.givenName forKey:@"givenName"];
    [user setValue:self.formattedName forKey:@"formattedName"];
    [user setValue:self.emailAddresses forKey:@"emailAddresses"];
    [user setValue:self.phoneNumbers forKey:@"phoneNumbers"];
    [user setValue:self.addresses forKey:@"addresses"];
    [user setValue:self.groups forKey:@"groups"];
    [user setValue:[NSNumber numberWithBool:self.active] forKey:@"active"];
    [user setValue:self.photos forKey:@"photos"];

    return user;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

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

        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeUserName] forKey:@"userName"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeFamilyName] forKey:@"familyName"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeGivenName] forKey:@"givenName"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeFormattedName] forKey:@"formattedName"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributePhotos] forKey:@"photos"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeEmails] forKey:@"emailAddresses"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributePhoneNumbers] forKey:@"phoneNumbers"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeAddresses] forKey:@"addresses"];
        [self setValue:[aDecoder decodeObjectForKey:MASIdMgmtUserAttributeGroups] forKey:@"groups"];
        [self setValue:[NSNumber numberWithBool:[aDecoder decodeBoolForKey:MASIdMgmtUserAttributeActive]] forKey:@"active"];
    }
    
    return self;
}

@end
