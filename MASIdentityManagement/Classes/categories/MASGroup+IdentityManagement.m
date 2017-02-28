//
//  MASGroup+IdentityManagement.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASGroup+IdentityManagement.h"

#import "MASFilter.h"
#import "MASFilteredRequest.h"
#import "MASGroup+MASIdentityManagementPrivate.h"
#import "Helpers.h"
#import "NSError+MASIdentityManagementPrivate.h"


static NSString *const kMASGroupPathFormat = @"%@/Groups";

static NSString *const kMASGroupPathDoubleObjectFormat = @"%@/%@";

static NSString *const kMASGroupFilterByDisplayNameEqualsFormat = @"displayName eq \"%@\"";
static NSString *const kMASGroupFilterByMembersValueEqualsFormat = @"members.value eq \"%@\"";
static NSString *const kMASGroupFilterByOwnerValueEqualsFormat = @"owner.value eq \"%@\"";

static NSString *const kMASGroupScimOperations = @"Operations";
static NSString *const kMASGroupScimPath = @"path";
static NSString *const kMASGroupScimSchemas = @"schemas";
static NSString *const kMASGroupScimSchemaCore = @"urn:ietf:params:scim:schemas:core:2.0:Group";
static NSString *const kMASGroupScimSchemaMessagesPatchOp = @"urn:ietf:params:scim:api:messages:2.0:PatchOp";


@implementation MASGroup (IdentityManagement)


# pragma mark - Basic Group Retrieval

///--------------------------------------
/// @name Basic Group Retrieval
///--------------------------------------


+ (void)getAllGroupsWithCompletion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion
{
    DLog(@"\n\ncalled\n\n");
    
    //
    // Create the empty filtered request
    //
    MASFilteredRequest *request = [MASFilteredRequest filteredRequest];
    
    //
    // Execute the filtered request
    //
    [self getGroupsByFilteredRequest:request completion:completion];
}


+ (void)getAllGroupsSortedByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *groupsList, NSError *error, NSUInteger totalResults))completion
{
    DLog(@"\n\ncalled with sortedByAttribute: %@, sortOrder: %@, pageRange: %@, includedAttributes: %@ and excludedAttributes: %@\n\n",
        sortByAttribute, (sortOrder ? MASIdMgmtSortOrderAscending : MASIdMgmtSortOrderDescending),
        NSStringFromRange(pageRange), includedAttributes, excludedAttributes);
 
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
    [self getGroupsByFilteredRequest:filteredRequest completion:completion];
}


+ (void)getGroupByObjectId:(NSString *)objectId
    completion:(void (^)(MASGroup *group, NSError *error))completion
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
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASGroupPathFormat,scimEndpoint];
    
    //
    // Construct pathURL with objectId
    //
    pathURL = [NSString stringWithFormat:kMASGroupPathDoubleObjectFormat, pathURL, objectId];
    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup getGroupByObjectId) received response:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            NSDictionary *responseDic = [responseInfo valueForKey:MASResponseInfoBodyInfoKey];
            
            if ([responseDic count] > 0) {
                
                //
                //Parse the response into MASGroup object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:responseDic];
                
                if (completion) {
                    
                    completion(group, nil);
                }
                
            }
            else {
                
                if (completion) {
                    
                    completion(nil, nil);
                }
            }
        }
        else {
            
            if (completion) {
                
                completion(nil,error);
            }
        }
    }];
}


+ (void)getGroupByObjectId:(NSString *)objectId
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
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtGroupAttributeId equalTo:objectId];
    
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
    [self getGroupsByFilteredRequest:filteredRequest completion:^(NSArray *userList, NSError *error, NSUInteger totalResults)
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
        if(completion)
        {
            completion([userList count] > 0 ? userList[0] : nil, error);
        }
    }];
}


+ (void)getGroupByGroupName:(NSString *)groupName
    completion:(void (^)(MASGroup *group, NSError *error))completion
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
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtGroupAttributeDisplayName equalTo:groupName];
    
    //
    // Create the filtered request
    //
    MASFilteredRequest *filteredRequest = [MASFilteredRequest filteredRequest];
    
    filteredRequest.filter = filter;
    
    //
    // Execute the filtered request
    //
    [self getGroupsByFilteredRequest:filteredRequest completion:^(NSArray *userList, NSError *error, NSUInteger totalResults)
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


+ (void)getGroupByGroupName:(NSString *)groupName
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
    MASFilter *filter = [MASFilter filterByAttribute:MASIdMgmtGroupAttributeDisplayName equalTo:groupName];
    
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
    [self getGroupsByFilteredRequest:filteredRequest completion:^(NSArray *userList, NSError *error, NSUInteger totalResults)
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


# pragma mark - Filtered Request Group Retrieval

+ (void)getGroupsByFilteredRequest:(MASFilteredRequest *)filteredRequest
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
    NSMutableString *pathURL = [NSMutableString stringWithFormat:kMASGroupPathFormat, scimEndpoint];
    
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
        DLog(@"(MASGroups getGroupsByFilteredRequest) received response info:\n\n%@\n\n", responseInfo);
        
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
        NSMutableArray *groupList = [[NSMutableArray alloc] init];
        MASGroup *group;
        for (NSDictionary *resourceInfo in resourcesList)
        {
            //
            // Parse the response into MASGroup object
            //
            group = [[MASGroup alloc] initWithAttributes:resourceInfo];
                
            [groupList addObject:group];
        }
            
        //
        // Notify the block
        //
        if (completion) completion([groupList copy], nil, totalItemsResults);
    }];
}


# pragma mark - Advanced Filtering Group Retrieval

+ (void)getGroupsByFilterExpression:(NSString *)filterExpression
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
    [self getGroupsByFilteredRequest:filteredRequest completion:completion];
}


#pragma mark - CRUD

- (void)saveInBackgroundWithCompletion:(void (^)(MASGroup *group, NSError *error))completion
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
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASGroupPathFormat, scimEndpoint];
    
    //
    //Build Parameters
    //
    NSArray *schemas = @[  kMASGroupScimSchemaCore ];
    NSDictionary *owner = @{ MASIdMgmtValue: self.owner ? self.owner : @""};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   
        schemas, kMASGroupScimSchemas,
        self.groupName, MASIdMgmtGroupAttributeDisplayName,
        self.members, MASIdMgmtGroupAttributeMembers, nil];
    
    if (self.owner)
    {
        [params setObject:owner forKey:MASIdMgmtGroupAttributeOwner];
    }
    
    if (!self.objectId) {

        //
        //Creating new Group
        //
        
        //
        //User MAS Object to make the security call to the Gateway
        //
        [MAS postTo:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
            
            DLog(@"(MASGroup save) received response:\n\n%@\n\n", responseInfo);
            
            if (!error) {
                
                NSDictionary *responseDic = [responseInfo valueForKey:MASResponseInfoBodyInfoKey];
                
                if ([responseDic count] > 0) {
                    
                    //
                    //Parse the response into MASGroup object
                    //
                    MASGroup *group = [[MASGroup alloc] initWithAttributes:responseDic];
                    
                    if (completion) {
                        
                        completion(group,nil);
                    }
                }
                else {
                    
                    NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorMASResponseInfoBodyEmpty errorDomain:kSDKErrorDomain];
                    
                    if (completion) {
                        
                        completion(nil,localizedError);
                    }
                }
            }
            else {
                
                if (completion) {
                    
                    completion(nil,error);
                }
            }
        }];
    }
    else {
        
        //
        //Updating Current Group
        //
        
        //
        //Build the PathURL
        //
        pathURL = [NSString stringWithFormat:kMASGroupPathDoubleObjectFormat, pathURL, self.objectId];

        //
        //Adding Group ID to params
        //
        NSDictionary *paramsID = @{ MASIdMgmtGroupAttributeId : self.objectId} ;
        [params addEntriesFromDictionary:paramsID];
        
        
        //
        //User MAS Object to make the security call to the Gateway
        //
        [MAS putTo:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
            
            DLog(@"(MASGroup update) received response:\n\n%@\n\n", responseInfo);
            
            if (!error) {
                
                NSDictionary *responseDic = [responseInfo valueForKey:MASResponseInfoBodyInfoKey];
                
                if ([responseDic count] > 0) {
                    
                    //
                    //Parse the response into MASGroup object
                    //
                    MASGroup *group = [[MASGroup alloc] initWithAttributes:responseDic];
                    
                    if (completion) {
                        
                        completion(group,nil);
                    }
                }
                else {
                    
                    NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorMASResponseInfoBodyEmpty errorDomain:kSDKErrorDomain];
                    
                    if (completion) {
                        
                        completion(nil,localizedError);
                    }
                }
            }
            else {
                
                if (completion) {
                    
                    completion(nil,error);
                }
            }
        }];
    }
}


- (void)deleteInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    //
    //  Validate user's session
    //
    if (![MASUser currentUser] || ![MASUser currentUser].isAuthenticated)
    {
        if (completion)
        {
            NSError *error = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorUserNotAuthenticated errorDomain:kSDKErrorDomain];
            completion(NO, error);
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
            completion(NO, localizedError);
        }
        
        return;
    }
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:kMASGroupPathFormat, scimEndpoint];
    
    //
    // Construct pathURL with objectId
    //
    pathURL = [NSString stringWithFormat:kMASGroupPathDoubleObjectFormat, pathURL, self.objectId];
    
    //
    //User MAS Object to make the security call to the Gateway
    //
    [MAS deleteFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
       
        DLog(@"(MASGroup delete) received response:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            if (completion) {
                
                completion(YES,nil);
            }
        }
        else {
            
            if (completion) {
                
                completion(NO,error);
            }
        }
    }];
}


- (void)addMember:(MASUser *)user completion:(void (^)(MASGroup *group, NSError *error))completion
{
    [self updateGroupMember:user withOperation:MASGroupMemberOperationAdd completion:completion];
}


- (void)removeMember:(MASUser *)user completion:(void (^)(MASGroup *group, NSError *error))completion;
{
    [self updateGroupMember:user withOperation:MASGroupMemberOperationRemove completion:completion];
}


- (void)updateGroupMember:(MASUser *)user withOperation:(MASGroupMemberOperation)operation completion:(void (^)(MASGroup *group, NSError *error))completion
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
    // Check for user
    //
    if (!user)
    {
        NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorMissingParameter errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(nil,localizedError);
        }
        
        return;
    }
    
    
    //
    //Check if is a new unsaved Group
    //
    if (!self.objectId) {
        
        NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorGroupNotFound errorDomain:kSDKErrorDomain];
        
        if (completion) {
            
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
    NSString *pathURL = [NSString stringWithFormat:kMASGroupPathFormat, scimEndpoint];
    
    //
    // Construct pathURL with objectId
    //
    pathURL = [NSString stringWithFormat:kMASGroupPathDoubleObjectFormat, pathURL, self.objectId];
    
    
    //
    // Build Parameters
    //
    NSArray *schemas = @[ kMASGroupScimSchemaMessagesPatchOp ];
    
    NSArray *memberValue = @[ @{ MASIdMgmtDisplay : user.userName,
                                 MASIdMgmtValue : user.objectId }];
    
    NSString *operator;
    
    switch (operation) {
            
        case MASGroupMemberOperationAdd:
            operator = MASIdMgmtOperationAdd;
            break;

        case MASGroupMemberOperationRemove:
            operator = MASIdMgmtOperationRemove;
            break;
    }

    NSArray *operationArray = @[ @{ MASIdMgmtOp : operator,
                                    kMASGroupScimPath : MASIdMgmtGroupAttributeMembers,
                                    MASIdMgmtValue : memberValue } ];
    
    NSDictionary *params = @{ kMASGroupScimSchemas : schemas,
                              kMASGroupScimOperations : operationArray };
    
    
    //
    // User MAS Object to make the security call to the Gateway
    //
    [MAS patchTo:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup Members Update) received response:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            NSDictionary *responseDic = [responseInfo valueForKey:MASResponseInfoBodyInfoKey];
            
            if ([responseDic count] > 0) {
                
                //
                //Parse the response into MASGroup object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:responseDic];
                
                if (completion) {
                    
                    completion(group,nil);
                }
            }
            else {
                
                NSError *localizedError = [NSError errorForIdentityManagementErrorCode:MASIdentityManagementErrorMASResponseInfoBodyEmpty errorDomain:kSDKErrorDomain];
                
                if (completion) {
                    
                    completion(nil,localizedError);
                }
            }
        }
        else {

            if (completion) {
                
                completion(nil,error);
            }
        }
    }];
}


# pragma mark - Print Attributes

- (void)listAttributes
{
    DLog(@"%@", self._attributes);
}

@end
