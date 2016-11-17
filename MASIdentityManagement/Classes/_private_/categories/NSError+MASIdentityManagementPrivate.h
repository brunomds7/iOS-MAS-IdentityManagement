//
//  NSError+MASIdentityManagementPrivate.h
//  MASIdentityManagement
//
//  Created by Hun Go on 2016-11-17.
//  Copyright © 2016 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MASIdentityManagementConstants.h"

@interface NSError (MASIdentityManagementPrivate)

/**
 * Creates an NSError for the given MASIdentityManagementError.  These errors will fall
 * under the specified domain in parameter.
 *
 * This version is a convenience version without the info:(NSDictionary *)info
 * parameter for those that don't need to add any custom info.
 *
 * All errors will include the following standard keys with applicable values:
 *
 *    NSLocalizedDescriptionKey
 *
 * @param errorCode The MASIdentityManagementError which identifies the error.
 * @param errorDomain The NSString of error domain.
 * @returns Returns the NSError instance.
 */
+ (NSError *)errorForIdentityManagementErrorCode:(MASIdentityManagementError)errorCode errorDomain:(NSString *)errorDomain;



/**
 * Creates an NSError for the given MASIdentityManagementError.  These errors will fall
 * under the sepcified domain in parameter.
 *
 * All errors will include the following standard keys with applicable values:
 *
 *    NSLocalizedDescriptionKey
 *
 * @param errorCode The MASIdentityManagementError which identifies the error.
 * @param info An additional NSDictionary of custom values that can be included
 * in addition to the defaults included by this method.  Optional, nil is allowed.
 * @param errorDomain The NSString which identifies the domain of the error.
 * @returns Returns the NSError instance.
 */
+ (NSError *)errorForIdentityManagementErrorCode:(MASIdentityManagementError)errorCode info:(NSDictionary *)info errorDomain:(NSString *)errorDomain;


@end
