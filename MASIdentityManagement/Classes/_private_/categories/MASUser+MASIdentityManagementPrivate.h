//
//  MASUser+MASIdentityManagementPrivate.h
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASUser (MASIdentityManagementPrivate)


# pragma mark - Properties

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
