//
//  MASUser+MASIdentityManagementPrivate.h
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-08-25.
//  Copyright (c) 2015 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>


@interface MASUser (MASIdentityManagementPrivate)


# pragma mark - Properties

@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *familyName;
@property (nonatomic, copy, readwrite) NSString *givenName;
@property (nonatomic, copy, readwrite) NSString *formattedName;
@property (nonatomic, copy, readwrite) NSDictionary *emailAddresses;
@property (nonatomic, copy, readwrite) NSDictionary *phoneNumbers;
@property (nonatomic, copy, readwrite) NSDictionary *addresses;
@property (nonatomic, copy, readwrite) NSDictionary *photos;
@property (nonatomic, copy, readwrite) NSArray *groups;
@property (nonatomic, assign, readwrite) BOOL active;
@property (nonatomic, copy, readwrite) NSMutableDictionary *_attributes;


# pragma mark - Lifecycle

/**
 *  Init the object with passed attributes in a form of NSDictionary
 *
 *  @param attributes NSDictionary to be used as attributes
 *
 *  @return The instance of the MASUser object
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end