//
//  MASUser+IdentityManagement.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASUser+IdentityManagement.h"

#import <MASFoundation/MASFoundation.h>
#import "MASFilter.h"
#import "MASFilteredRequest.h"
#import "MASUser+MASIdentityManagementPrivate.h"
#import "Helpers.h"
#import "SearchResponseModel.h"
#import "NSError+MASIdentityManagementPrivate.h"


static NSString *const kMASUserPathFormat = @"%@/Users";
static NSString *const kMASUserAttributesPathFormat = @"%@/Users/%@?attributes=%@";

static NSString *const kMASUserBasicObjectFormat = @"%@";
static NSString *const kMASUserPathDoubleObjectFormat = @"%@/%@";
static NSString *const kMASUserBasicUnsignedLongFormat = @"%lu";

static NSString *const kMASUserFilterByUserNameContainsFormat = @"userName co \"%@\"";

typedef void (^GetUsersSuccess)(SearchResponseModel *searchResponse);
typedef void (^GetUsersFailure)(NSError *error);


@implementation MASUser (IdentityManagement)


# pragma mark - Private

+ (NSDictionary *)paramsForSearchQuery:(NSString *)query range:(NSRange)pageRange
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    //
    // If there is a query set the value
    //
    if (query) [dictionary setObject:[NSString stringWithFormat:kMASUserBasicObjectFormat, query] forKey:MASIdMgmtFilter];
    
    //
    // Set the pagination values
    //
    [dictionary setObject:[NSString stringWithFormat:kMASUserBasicUnsignedLongFormat, (unsigned long)pageRange.location] forKey:MASIdMgmtStartIndex];
    [dictionary setObject:[NSString stringWithFormat:kMASUserBasicUnsignedLongFormat, (unsigned long)pageRange.length] forKey:MASIdMgmtCount];
    
    return dictionary;
}


# pragma mark - Basic User Retrieval

///--------------------------------------
/// @name Basic User Retrieval
///--------------------------------------


+ (void)getAllUsersSortedByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error, 0);
        }
        
        return;
    }
    
    //DLog(@"\n\ncalled with sortedByAttribute: %@, sortOrder: %@, pageRange: %@, includedAttributes: %@ and excludedAttributes: %@\n\n",
    //    sortByAttribute, (sortOrder ? MASIdMgmtSortOrderAscending : MASIdMgmtSortOrderDescending),
    //    NSStringFromRange(pageRange), includedAttributes, excludedAttributes);
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.sortByAttribute = sortByAttribute;
    filteredRequest.sortOrder = sortOrder;
    filteredRequest.paginationRange = pageRange;
    filteredRequest.includedAttributes = includedAttributes;
    
    //
    // Only need to try to add these if there are no included attributes
    //
    if(!filteredRequest.includedAttributes || filteredRequest.includedAttributes.count > 0)
    {
        filteredRequest.excludedAttributes = excludedAttributes;
    }
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:filteredRequest completion:completion];
}


+ (void)getAllUsersWithUsernameContaining:(NSString *)value
    sortByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error, 0);
        }
        
        return;
    }
    
    //
    // Create the filter
    //
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtUserAttributeUserName contains:value];
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.filter = filter;
    filteredRequest.sortByAttribute = sortByAttribute;
    filteredRequest.sortOrder = sortOrder;
    filteredRequest.paginationRange = pageRange;
    filteredRequest.includedAttributes = includedAttributes;
    
    //
    // Only need to try to add these if there are no included attributes
    //
    if(!filteredRequest.includedAttributes || filteredRequest.includedAttributes.count > 0)
    {
        filteredRequest.excludedAttributes = excludedAttributes;
    }
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:filteredRequest completion:completion];
}


+ (void)getUserByObjectId:(NSString *)objectId
    completion:(void (^)(MASUser *user, NSError *error))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error);
        }
        
        return;
    }
    
    //
    // Check for objectId
    //
    if (!objectId)
    {
        NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorMissingParameter errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(nil,localizedError);
        }
        
        return;
    }
    
    //
    // SCIM endpoint from configuration
    //
    NSString *scimEndpoint = [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey];
    
    //
    // Validate pathURL
    //
    if (!scimEndpoint || ![scimEndpoint isKindOfClass:[NSString class]] || scimEndpoint.length == 0)
    {
        NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorInvalidEndpoint errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(nil, localizedError);
        }
        
        return;
    }
    
    //
    // Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASUserPathFormat, scimEndpoint];
    
    //
    // Construct pathURL with objectId
    //
    pathURL = [NSString stringWithFormat:kMASUserPathDoubleObjectFormat, pathURL, objectId];
    
    //
    // Execute the operation
    //
    [MAS getFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error)
    {
        DLog(@"(MASUser getUserByObjectId) received response:\n\n%@\n\n", responseInfo);
        
        //
        // Error
        //
        if (error)
        {
            if (completion) completion(nil, error);
        
            return;
        }
    
        //
        // If body information found
        //
        NSDictionary *bodyInfo = [responseInfo valueForKey:MASResponseInfoBodyInfoKey];
        if ([bodyInfo count] > 0)
        {
            //
            // Parse the response info into the MASUser object
            //
            MASUser *user = [[MASUser alloc] initWithAttributes:bodyInfo];
        
            //
            // Notify the block
            //
            if (completion) completion(user, nil);
        }
        
        //
        // Empty result
        //
        else
        {
            
            //
            // Notify the block
            //
            if (completion) completion(nil, nil);
        }
    }];
}


+ (void)getUserByObjectId:(NSString *)objectId
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(MASUser *user, NSError *error))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error);
        }
        
        return;
    }
    
    //
    // Create the filter
    //
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtUserAttributeId equalTo:objectId];
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.filter = filter;
    filteredRequest.includedAttributes = includedAttributes;
    
    //
    // Only need to try to add these if there are no included attributes
    //
    if(!filteredRequest.includedAttributes || filteredRequest.includedAttributes.count > 0)
    {
        filteredRequest.excludedAttributes = excludedAttributes;
    }
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:filteredRequest completion:^(NSArray *userList, NSError *error, NSUInteger totalResults)
    {
        //
        // Error
        //
        if(error)
        {
            //
            // Notify the block
            //
            if(completion) completion(nil, error);
            return;
        }
        
        //
        // Notify the block
        //
        if(completion) completion([userList count] > 0 ? userList[0] : nil, error);
    }];
}


+ (void)getUserByUserName:(NSString *)userName
    completion:(void (^)(MASUser *user, NSError *error))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error);
        }
        
        return;
    }
    
    //
    // Create the filter
    //
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtUserAttributeUserName equalTo:userName];
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.filter = filter;
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:filteredRequest completion:^(NSArray *userList, NSError *error, NSUInteger totalResults)
    {
        //
        // Error
        //
        if(error)
        {
            //
            // Notify the block
            //
            if(completion) completion(nil, error);
            return;
        }
        
        //
        // Notify the block
        //
        if(completion) completion([userList count] > 0 ? userList[0] : nil, error);
    }];
}


+ (void)getUserByUserName:(NSString *)userName
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(MASUser *user, NSError *error))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error);
        }
        
        return;
    }
    
    //
    // Create the filter
    //
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtUserAttributeUserName equalTo:userName];
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.filter = filter;
    filteredRequest.includedAttributes = includedAttributes;
    
    //
    // Only need to try to add these if there are no included attributes
    //
    if(!filteredRequest.includedAttributes || filteredRequest.includedAttributes.count > 0)
    {
        filteredRequest.excludedAttributes = excludedAttributes;
    }
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:filteredRequest completion:^(NSArray *userList, NSError *error, NSUInteger totalResults)
    {
        //
        // Error
        //
        if(error)
        {
            //
            // Notify the block
            //
            if(completion) completion(nil, error);
            return;
        }
        
        //
        // Notify the block
        //
        if(completion) completion([userList count] > 0 ? userList[0] : nil, error);
    }];
}


# pragma mark - Filtered Request User Retrieval

+ (void)getUsersByFilteredRequest:(MASFilteredRequest *)filteredRequest
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    DLog(@"\n\nThe filtered request is: %@\n\n", [filteredRequest asStringQueryPath]);
    
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error, 0);
        }
        
        return;
    }
    
    //
    // SCIM endpoint from configuration
    //
    NSString *scimEndpoint = [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey];
    
    //
    // Validate pathURL
    //
    if (!scimEndpoint || ![scimEndpoint isKindOfClass:[NSString class]] || scimEndpoint.length == 0)
    {
        NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorInvalidEndpoint errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(nil, localizedError, 0);
        }
        
        return;
    }
    
    //
    // Build the PathURL
    //
    NSMutableString *pathURL = [NSMutableString stringWithFormat:kMASUserPathFormat, scimEndpoint];
    
    //
    // Filter Request
    //
    if(filteredRequest)
    {
        [pathURL appendString:[filteredRequest asStringQueryPath]];
    }
    
    DLog(@"\n\nThe full path is: %@\n\n", [pathURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    //
    // Execute the operation
    //
    [MAS getFrom:[pathURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error)
    {
        DLog(@"(MASUser getUsersByFilteredRequest) received response info:\n\n%@\n\n", responseInfo);
        
        //
        // Retrieve the total items result
        //
        NSUInteger totalItemsResults = [[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:MASIdMgmtTotalResults] integerValue];
        
        //
        // Error
        //
        if (error)
        {
            //
            // Notify the block
            //
            if (completion) completion(nil, error, totalItemsResults);
        
            //
            // Stop here
            //
            return;
        }
        
        //
        // Retrieve the resources from the response
        //
        NSArray *resourcesList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:MASIdMgmtResources];
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        MASUser *user;
        for (NSDictionary *resourceInfo in resourcesList)
        {
            //
            // Parse the response into MASUser object
            //
            user = [[MASUser alloc] initWithAttributes:resourceInfo];
                
            [userList addObject:user];
        }
            
        //
        // Notify the block
        //
        if (completion) completion([userList copy], nil, totalItemsResults);
    }];
}


# pragma mark - Advanced Filtering User Retrieval

+ (void)getUsersByFilterExpression:(NSString *)filterExpression
    sortByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(nil, error, 0);
        }
        
        return;
    }
    
    //
    // Create the filter
    //
    MASFilter *filter = [MASFilter fromStringFilterExpression:filterExpression];
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.filter = filter;
    filteredRequest.sortByAttribute = sortByAttribute;
    filteredRequest.sortOrder = sortOrder;
    filteredRequest.paginationRange = pageRange;
    filteredRequest.includedAttributes = includedAttributes;
    
    //
    // Only need to try to add these if there are no included attributes
    //
    if(!filteredRequest.includedAttributes || filteredRequest.includedAttributes.count > 0)
    {
        filteredRequest.excludedAttributes = excludedAttributes;
    }
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:filteredRequest completion:completion];
}


# pragma mark - User Images

- (void)getThumbnailImageWithCompletion:(void (^)(UIImage *image, NSError *error))completion
{
    [MASUser getUserByUserName:self.userName
        includedAttributes:@[ MASIdMgmtUserAttributePhotos ]
        excludedAttributes:nil
        completion:^(MASUser *user, NSError *error)
    {
        if(completion) completion(user.photos[MASIdMgmtUserAttributeThumbnailPhoto], error);
    }];
}

# pragma mark - Instance Methods

- (id)objectForKey:(id)key
{
    return [self._attributes objectForKey:key];
}


- (void)setObject:(id)object forKey:(id <NSCopying>)key
{
    [self._attributes setObject:object forKey:key];
}


- (id)objectForKeyedSubscript:(id)key
{
    return self._attributes[key];
}


- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    self._attributes[key] = obj;
}


# pragma mark - Print Attributes

- (void)listAttributes
{
    DLog(@"%@", self._attributes);
}

@end
