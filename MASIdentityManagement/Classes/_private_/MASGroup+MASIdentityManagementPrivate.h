//
//  MASGroup+MASIdentityManagementPrivate.h
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-11-28.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>

@interface MASGroup (MASIdentityManagementPrivate)

# pragma mark - Properties

@property (nonatomic, copy, readwrite) NSString *groupName;
@property (nonatomic, copy, readwrite) NSString *owner;
@property (nonatomic, copy, readwrite) NSArray *members;
@property (nonatomic, copy, readwrite) NSMutableDictionary *_attributes;

# pragma mark - Lifecycle

/**
 *  Init the object with passed attributes in a form of NSDictionary
 *
 *  @param attributes NSDictionary to be used as attributes
 *
 *  @return The instance of the MASGroup object
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
