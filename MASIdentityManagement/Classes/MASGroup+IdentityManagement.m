//
//  MASGroup+IdentityManagement.m
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-11-28.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import "MASGroup+IdentityManagement.h"
#import "Helpers.h"
#import "MASGroup+MASIdentityManagementPrivate.h"


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


# pragma mark - Filtered Request Group Retrieval

+ (void)getGroupsByFilteredRequest:(MASFilteredRequest *)filteredRequest
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion
{
    DLog(@"\n\nThe filtered request is: %@\n\n", [filteredRequest filterRequestAsString]);
    
    //
    // Build the PathURL
    //
    NSMutableString *pathURL = [NSMutableString stringWithFormat:@"%@/Groups",
        [[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    //
    // Filter Request
    //
    if(filteredRequest)
    {
        [pathURL appendString:[filteredRequest filterRequestAsString]];
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
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"totalResults"];
        
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
        NSArray *resourcesList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"Resources"];
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
    // Create the filter
    //
    MASFilter *filter = [MASFilter filterFromString:filterExpression];
    
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


#pragma mark - Instance methods
#pragma mark - CRUD methods

- (void)saveInBackgroundWithCompletion:(void (^)(MASGroup *group, NSError *error))completion
{
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    //Build Parameters
    //
    NSArray *schemas = @[@"urn:ietf:params:scim:schemas:core:2.0:Group"];
    NSDictionary *owner = @{@"value":self.owner};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   schemas, @"schemas",
                                   self.groupName, @"displayName",
                                   owner, @"owner",
                                   self.members, @"members",
                                   nil];
    
    
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
                    
                    NSString *message = NSLocalizedString(@"MASResponseIndoBody is empty", @"MASResponseIndoBody is empty");
                    
                    NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain code:MASIdentityManagementErrorMASResponseInfoBodyEmpty userInfo:@{NSLocalizedDescriptionKey : message}];
                    
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
        pathURL = [NSString stringWithFormat:@"%@/%@",pathURL, self.objectId];

        //
        //Adding Group ID to params
        //
        NSDictionary *paramsID = @{@"id":self.objectId};
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
                    
                    NSString *message = NSLocalizedString(@"MASResponseIndoBody is empty", @"MASResponseIndoBody is empty");
                    
                    NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain code:MASIdentityManagementErrorMASResponseInfoBodyEmpty userInfo:@{NSLocalizedDescriptionKey : message}];
                    
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
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    pathURL = [NSString stringWithFormat:@"%@/%@",pathURL, self.objectId];
    
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
    NSParameterAssert(user);
    
    //
    //Check if is a new unsaved Group
    //
    if (!self.objectId) {
        
        NSString *message = NSLocalizedString(@"Group not found. Perform SAVE action before adding members", Nil);
        
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain code:MASIdentityManagementErrorGroupNotFound userInfo:@{NSLocalizedDescriptionKey : message}];
        
        if (completion) {
            
            completion(nil,localizedError);
        }

        return;
    }
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    pathURL = [NSString stringWithFormat:@"%@/%@",pathURL, self.objectId];
    
    
    //
    //Build Parameters
    //
    NSArray *schemas = @[@"urn:ietf:params:scim:api:messages:2.0:PatchOp"];
    
    NSArray *memberValue = @[@{@"display":user.formattedName,
                               @"value":user.objectId}];
    
    NSString *operator;
    
    switch (operation) {
            
        case MASGroupMemberOperationAdd:
            operator = @"add";
            break;

        case MASGroupMemberOperationRemove:
            operator = @"remove";
            break;
    }

    NSArray *operationArray = @[@{@"op":operator,
                                @"path":@"members",
                                @"value":memberValue}];
    
    NSDictionary *params = @{@"schemas":schemas,
                                    @"Operations":operationArray};
    
    
    //
    //User MAS Object to make the security call to the Gateway
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
                
                NSString *message = NSLocalizedString(@"MASResponseIndoBody is empty", @"MASResponseIndoBody is empty");
                
                NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain code:MASIdentityManagementErrorMASResponseInfoBodyEmpty userInfo:@{NSLocalizedDescriptionKey : message}];
                
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
    DLog(@"%@",self._attributes);
}


# pragma mark - Deprecated

+ (void)getAllGroups:(NSRange)pageRange
          completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(pageRange.location != NSNotFound);
    
    //
    //Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    
    if (pageRange.location == NSNotFound) {
        
        pageRange = defaultRange;
    }
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    //Build Parameters
    //
    NSDictionary *params = [Helpers paramsForSearchQuery:nil range:pageRange];

    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup getAllGroups) received response info:\n\n%@\n\n", responseInfo);
        
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"totalResults"];
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"Resources"];
            
            
            for (NSDictionary *response in responseList) {
                
                //
                //Parse the response into MASGroup object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:(NSDictionary *)response];
                
                [list addObject:group];
            }
            
            if (completion) {
                
                completion([list copy],nil,totalItemsResults);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil, error, totalItemsResults);
            }
        }
    }];
}


+ (void)getGroupByObjectId:(NSString *)objectId
                completion:(void (^)(MASGroup *group, NSError *error))completion
{
    NSParameterAssert(objectId);

    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    pathURL = [NSString stringWithFormat:@"%@/%@",pathURL, objectId];
    
    
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
                    
                    completion(group,nil);
                }
                
            }
            else {
                
                NSString *message = NSLocalizedString(@"MASResponseIndoBody is empty", @"MASResponseIndoBody is empty");
                
                NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain code:MASIdentityManagementErrorMASResponseInfoBodyEmpty userInfo:@{NSLocalizedDescriptionKey : message}];
                
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


+ (void)getGroupsWithName:(NSString *)groupName
                    range:(NSRange)pageRange
               completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(groupName);
    
    //
    //Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    
    if (pageRange.location == NSNotFound) {
        
        pageRange = defaultRange;
    }
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    //Build Parameters
    //
    NSString *grpName = [NSString stringWithFormat:@"displayName eq \"%@\"",groupName];
    NSDictionary *params = [Helpers paramsForSearchQuery:grpName range:pageRange];
    
    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup getGroupWithName) received response info:\n\n%@\n\n", responseInfo);
        
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"totalResults"];
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"Resources"];
            
            for (NSDictionary *response in responseList) {
                
                //
                //Parse the response into MASUser object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:(NSDictionary *)response];
                
                [list addObject:group];
            }
            
            if (completion) {
                
                completion([list copy], nil, totalItemsResults);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil, error, totalItemsResults);
            }
        }
    }];
}


+ (void)getGroupsWithOwner:(NSString *)owner
                     range:(NSRange)pageRange
                completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(owner);
    
    //
    //Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    
    if (pageRange.location == NSNotFound) {
        
        pageRange = defaultRange;
    }
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    //Build Parameters
    //
    NSString *ownerFilter = [NSString stringWithFormat:@"owner.value eq \"%@\"",owner];
    NSDictionary *params = [Helpers paramsForSearchQuery:ownerFilter range:pageRange];
    
    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup getGroupWithName) received response info:\n\n%@\n\n", responseInfo);
        
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"totalResults"];
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"Resources"];
            
            for (NSDictionary *response in responseList) {
                
                //
                //Parse the response into MASUser object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:(NSDictionary *)response];
                
                [list addObject:group];
            }
            
            if (completion) {
                
                completion([list copy], nil, totalItemsResults);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil, error, totalItemsResults);
            }
        }
    }];
}


+ (void)getGroupsWithMember:(MASUser *)user
                      range:(NSRange)pageRange
                 completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(user);
    
    //
    //Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    
    if (pageRange.location == NSNotFound) {
        
        pageRange = defaultRange;
    }
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    //Build Parameters
    //
    NSString *ownerFilter = [NSString stringWithFormat:@"members.value eq \"%@\"",user.objectId];
    NSDictionary *params = [Helpers paramsForSearchQuery:ownerFilter range:pageRange];
    
    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup getGroupWithName) received response info:\n\n%@\n\n", responseInfo);
        
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"totalResults"];
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"Resources"];
            
            for (NSDictionary *response in responseList) {
                
                //
                //Parse the response into MASUser object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:(NSDictionary *)response];
                
                [list addObject:group];
            }
            
            if (completion) {
                
                completion([list copy], nil, totalItemsResults);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil, error, totalItemsResults);
            }
        }
    }];
}


+ (void)getGroupsUsingFilter:(NSString *)filter
                       range:(NSRange)pageRange
                  completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion
{
    NSParameterAssert(filter);
    
    
    //
    //Default Range starting with 1 and lengh of 10
    //
    NSRange defaultRange = NSMakeRange(1, 10);
    
    if (pageRange.location == NSNotFound) {
        
        pageRange = defaultRange;
    }
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/Groups",[[MASConfiguration currentConfiguration] endpointPathForKey:MASSCIMEndPointKey]];
    
    
    //
    //Build Parameters
    //
    NSDictionary *params = [Helpers paramsForSearchQuery:filter range:pageRange];

    
    //
    //User MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASGroup getGrouprUsingFilter) received response:\n\n%@\n\n", responseInfo);
        
        NSUInteger totalItemsResults = (NSUInteger)[[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"totalResults"];
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"Resources"];
            
            for (NSDictionary *response in responseList) {
                
                //
                //Parse the response into MASUser object
                //
                MASGroup *group = [[MASGroup alloc] initWithAttributes:(NSDictionary *)response];
                
                [list addObject:group];
            }
            
            if (completion) {
                
                completion([list copy],nil, totalItemsResults);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil, error, totalItemsResults);
            }
        }
    }];
}

@end
