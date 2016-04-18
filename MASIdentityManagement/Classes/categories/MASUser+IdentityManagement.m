//
//  MASUser+IdentityManagement.m
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-07-23.
//  Copyright (c) 2015 CA Technologies. All rights reserved.
//

#import "MASUser+IdentityManagement.h"

#import <MASFoundation/MASFoundation.h>
#import "MASFilter.h"
#import "MASFilteredRequest.h"
#import "MASUser+MASIdentityManagementPrivate.h"
#import "Helpers.h"
#import "SearchResponseModel.h"


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


+ (void)getAllUsersWithCompletion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    //DLog(@"\n\ncalled\n\n");
    
    //
    // Create the empty filtered request
    //
    MASFilteredRequest *request = [MASFilteredRequest filteredRequest];
    
    //
    // Execute the filtered request
    //
    [self getUsersByFilteredRequest:request completion:completion];
}


+ (void)getAllUsersSortedByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
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
    NSParameterAssert(objectId);
    
    //
    // Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASUserPathFormat,
        [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
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
        // Error
        //
        else
        {
            NSString *message = NSLocalizedString(@"MASResponseIndoBody is empty", @"MASResponseIndoBody is empty");
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain code:MASIdentityManagementErrorMASResponseInfoBodyEmpty userInfo:@{NSLocalizedDescriptionKey : message}];
            
            //
            // Notify the block
            //
            if (completion) completion(nil,localizedError);
        }
    }];
}


+ (void)getUserByObjectId:(NSString *)objectId
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(MASUser *user, NSError *error))completion
{
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
        if(completion) completion(userList[0], error);
    }];
}


+ (void)getUserByUserName:(NSString *)userName
    completion:(void (^)(MASUser *user, NSError *error))completion
{
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
        if(completion) completion(userList[0], error);
    }];
}


+ (void)getUserByUserName:(NSString *)userName
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(MASUser *user, NSError *error))completion
{
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
        if(completion) completion(userList[0], error);
    }];
}


# pragma mark - Filtered Request User Retrieval

+ (void)getUsersByFilteredRequest:(MASFilteredRequest *)filteredRequest
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    DLog(@"\n\nThe filtered request is: %@\n\n", [filteredRequest asStringQueryPath]);
    
    //
    // Build the PathURL
    //
    NSMutableString *pathURL = [NSMutableString stringWithFormat:kMASUserPathFormat,
        [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
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
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:MASIdMgmtTotalResults];
        
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



# pragma mark - Deprecated

///--------------------------------------
/// @name Deprecated
///--------------------------------------


+ (void)getAllUsers:(NSRange)pageRange
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(pageRange.location != NSNotFound);
    
    //
    // Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    if (pageRange.location == NSNotFound)
    {
        pageRange = defaultRange;
    }
    
    
    //
    // Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASUserPathFormat,
        [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    // Build Parameters
    //
    NSDictionary *params = [self paramsForSearchQuery:nil range:pageRange];
    
    
    //
    // Execute the operation
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASUser getAllUsers) received response info:\n\n%@\n\n", responseInfo);
        
        //
        // Retrieve the total items result
        //
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:MASIdMgmtTotalResults];
        
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


+ (void)getUsersWithUsername:(NSString *)userName
    range:(NSRange)pageRange
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(userName);
    
    //
    // Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    if (pageRange.location == NSNotFound)
    {
        pageRange = defaultRange;
    }
    
    //
    // Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASUserPathFormat,
        [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];

    //
    // Build Parameters
    //
    NSString *usrName = [NSString stringWithFormat:kMASUserFilterByUserNameContainsFormat,
        userName];
    NSDictionary *params = [self paramsForSearchQuery:usrName range:pageRange];
    
    //
    // Execute the operation
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error)
    {
        //
        // Retrieve the total items result
        //
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:MASIdMgmtTotalResults];

        //
        // If error
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
            // Parse the resource info into a MASUser object
            //
            user = [[MASUser alloc] initWithAttributes:resourceInfo];
            
            //
            // Add it to the user list
            //
            [userList addObject:user];
        }
            
        //
        // Notify the block
        //
        if (completion) completion([userList copy], nil, totalItemsResults);
    }];
}


+ (void)getUserByObjectId:(NSString *)objectId
    attributes:(MASUserAttributes)attributes
    completion:(void (^)(MASUser *user, NSError *error))completion
{
    NSParameterAssert(objectId);
    
    //
    // All, the default
    //
    if (attributes & MASUserAttributeAll)
    {
        [MASUser getUserByObjectId:objectId completion:completion];
        
        return;
    }
    
    //
    // Build the query path
    //
    NSMutableString *queryPath = [NSMutableString new];
    
    //
    // Name
    //
    if((attributes & MASUserAttributeName) == MASUserAttributeName)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributeName];
    }
    
    //
    // UserName
    //
    if((attributes & MASUserAttributeUserName) == MASUserAttributeUserName)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributeUserName];
    }
    
    //
    // Active
    //
    if((attributes & MASUserAttributeActive) == MASUserAttributeActive)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributeActive];
    }
    
    //
    // Addresses
    //
    if((attributes & MASUserAttributeAddresses) == MASUserAttributeAddresses)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributeAddresses];
    }
    
    //
    // Email Addresses
    //
    if((attributes & MASUserAttributeEmailAddresses) == MASUserAttributeEmailAddresses)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributeEmails];
    }
    
    //
    // Groups
    //
    if((attributes & MASUserAttributeGroups) == MASUserAttributeGroups)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributeGroups];
    }
    
    //
    // Phone Numbers
    //
    if((attributes & MASUserAttributePhoneNumbers) == MASUserAttributePhoneNumbers)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributePhoneNumbers];
    }
    
    //
    // Photos
    //
    if((attributes & MASUserAttributePhotos) == MASUserAttributePhotos)
    {
        if(queryPath.length != 0) [queryPath appendString:MASIdMgmtComma];
        [queryPath appendString:MASIdMgmtUserAttributePhotos];
    }
    
    //
    // Build the full path URL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASUserAttributesPathFormat,
        [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey],
        objectId,
        queryPath];
    
    //
    // Execute the operation
    //
    [MAS getFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error)
    {
        //
        // Error
        //
        if (error)
        {
            //
            // Notify the block
            //
            if (completion) completion(nil,error);
        
            //
            // Stop here
            //
            return;
        }
        
        //
        // Retrieve the response body info
        //
        NSDictionary *bodyInfo = [responseInfo valueForKey:MASResponseInfoBodyInfoKey];
        MASUser *user;
        NSError *localizedError;
                
        //
        // If anything came back
        //
        if ([bodyInfo count] > 0)
        {
            //
            // Create the MASUser from the body info
            //
            user = [[MASUser alloc] initWithAttributes:bodyInfo];
        }
                
        //
        // Else if nothing came back trigger an error
        //
        else
        {
            NSString *errorMessage = NSLocalizedString(@"MASResponseInfoBody is empty", nil);
            localizedError = [NSError errorWithDomain:kSDKErrorDomain
                code:MASIdentityManagementErrorMASResponseInfoBodyEmpty
                userInfo:
                @{
                    NSLocalizedDescriptionKey : errorMessage
                }];
        }
                
        //
        // Trigger the completion block, if any
        //
        if (completion) completion(user, localizedError);
    }];
}

@end
