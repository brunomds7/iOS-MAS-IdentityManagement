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
    
    [self setValue:[[NSMutableDictionary alloc] initWithDictionary:attributes] forKey:@"_attributes"];
    
    return self;
}

@end
