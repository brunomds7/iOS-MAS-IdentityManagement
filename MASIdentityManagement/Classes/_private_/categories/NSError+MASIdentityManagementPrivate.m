//
//  NSError+MASIdentityManagementPrivate.m
//  MASIdentityManagement
//
//  Created by Hun Go on 2016-11-17.
//  Copyright © 2016 CA Technologies. All rights reserved.
//

#import "NSError+MASIdentityManagementPrivate.h"

@implementation NSError (MASIdentityManagementPrivate)

+ (NSError *)errorForIdentityManagementErrorCode:(MASIdentityManagementError)errorCode errorDomain:(NSString *)errorDomain
{
    return [self errorForIdentityManagementErrorCode:errorCode info:nil errorDomain:errorDomain];
}


+ (NSError *)errorForIdentityManagementErrorCode:(MASIdentityManagementError)errorCode info:(NSDictionary *)info errorDomain:(NSString *)errorDomain
{
    //
    // Standard error key/values
    //
    NSMutableDictionary *errorInfo = [NSMutableDictionary new];
    if(![info objectForKey:NSLocalizedDescriptionKey])
    {
        errorInfo[NSLocalizedDescriptionKey] = [self descriptionForIdentityManagementErrorCode:errorCode];
    }
    
    [errorInfo addEntriesFromDictionary:info];
    
    return [NSError errorWithDomain:errorDomain code:errorCode userInfo:errorInfo];
}


+ (NSString *)descriptionForIdentityManagementErrorCode:(MASIdentityManagementError)errorCode
{
    //
    // Detect code and respond appropriately
    //
    switch(errorCode)
    {
            //
            // Response
            //
        case MASIdentityManagementErrorMASResponseInfoBodyEmpty: return NSLocalizedString(@"MASResponseIndoBody is empty", @"MASResponseIndoBody is empty");
        
            //
            // Group
            //
        case MASIdentityManagementErrorGroupNotFound: return NSLocalizedString(@"Group not found. Perform SAVE action before adding members", @"Group not found. Perform SAVE action before adding members");
            
            //
            // Validation
            //
        case MASIdentityManagementErrorMissingParameter: return NSLocalizedString(@"Missing parameter", @"Missing parameter");
            
        default: return [NSString stringWithFormat:@"Unrecognized error code of value: %ld", (long)errorCode];
    }
}
@end
