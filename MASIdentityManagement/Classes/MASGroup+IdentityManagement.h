//
//  MASGroup+IdentityManagement.h
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-11-28.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>

#import "MASFilter.h"
#import "MASFilteredRequest.h"


/**
 *  This category enables Identity Management features to the group object
 */
@interface MASGroup (IdentityManagement)


# pragma mark - Basic Group Retrieval

///--------------------------------------
/// @name Basic Group Retrieval
///--------------------------------------


/**
 * Retrieves all 'MASGroup' objects.  Note, this version has no paging or filtering at all.  You will
 * receive not only all of the 'MASGroup' objects, but all their fields as well.
 *
 * @param completion Completion block with either the array of 'MASGroup' or 'NSError'.
 */
+ (void)getAllGroupsWithCompletion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASGroup' objects with various sorting, paging and included/excluded attribute options.
 *
 * @param sortByAttribute An attribute of the 'MASGroup' that can be used to sort the results. (optional)
 * @param sortOrder The 'MASFilteringRequestSortOrder' direction of the results.  Valid values are
 *     'MASFilteringRequestSortOrderAscending' and 'MASFilteringRequestSortOrderDescending'.
 * @param pageRange 'NSRange' containing pagination values.
 * @param includedAttributes 'NSArray' of 'NSString' attribute names to include in the results for each object.
 *     Note, if there attribute names included the excluded attributes are ignored. (optional)
 * @param excludedAttributes 'NSArray' of 'NSString' attribute names to exclude from the results for each object.
 *     Note, these will only take effect if there are no 'includedAttributes'. (optional)
 * @param completion Completion block with either the array of 'MASGroup' objects or NSError.
 */
+ (void)getAllGroupsSortedByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;



# pragma mark - Filtered Request Group Retrieval

///---------------------------------------------
/// @name Custom Filtered Request Group Retrieval
///---------------------------------------------


/**
 * Retrieves 'MASGroup' objects that matches the 'MASFilteredRequest'.
 *
 * @param filter The 'MASFilteredRequest; to filter results.
 * @param completion Completion block with either the array of 'MASGroup' objects or the 'NSError'.
 */
+ (void)getGroupsByFilteredRequest:(MASFilteredRequest *)filteredRequest
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;



# pragma mark - Advanced Filtering Group Retrieval

///----------------------------------------
/// @name Advanced Filtering Group Retrieval
///----------------------------------------


/**
 * Retrieves 'MASGroup' objects that matches the custom built filter expression and additional options.
 *
 * @param filterExpression The custom build 'NSString' filter expression.
 * @param sortByAttribute An attribute of the 'MASUser' that can be used to sort the results. (optional)
 * @param sortOrder The 'MASFilteringRequestSortOrder' direction of the results.  Valid values are
 *     'MASFilteringRequestSortOrderAscending' and 'MASFilteringRequestSortOrderDescending'.
 * @param pageRange 'NSRange' containing pagination values.
 * @param includedAttributes 'NSArray' of 'NSString' attribute names to include in the results for each object.
 *     Note, if there attribute names included the excluded attributes are ignored. (optional)
 * @param excludedAttributes 'NSArray' of 'NSString' attribute names to exclude from the results for each object.
 *     Note, these will only take effect if there are no 'includedAttributes'. (optional)
 * @param completion Completion block with either the array of 'MASGroup' objects or NSError.
 */
+ (void)getGroupsByFilterExpression:(NSString *)filterExpression
    sortByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;



# pragma mark - Instance Methods

///----------------------------------------
/// @name Instance Methods
///----------------------------------------

/**
 * Saves the group object in the cloud.
 *
 * @param completion Completion block with either the MASGroup object or the Error message.
 */
- (void)saveInBackgroundWithCompletion:(void (^)(MASGroup *group, NSError *error))completion;


/**
 * Deletes the group object from the cloud.
 *
 * @param completion Completion block with either Success boolean or the Error message.
 */
- (void)deleteInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion;


/**
 *  Adds an user to the group.
 *
 *  @param user MASUser object
 *  @param completion Completion block with either the MASGroup object or the Error message
 */
- (void)addMember:(MASUser *)user completion:(void (^)(MASGroup *group, NSError *error))completion;


/**
 * Removes an user from the group
 *
 * @param user MASUser object
 * @param completion Completion block with either the MASGroup object or the Error message
 */
- (void)removeMember:(MASUser *)user completion:(void (^)(MASGroup *group, NSError *error))completion;



# pragma mark - Print Attributes

///--------------------------------------
/// @name Print Attributes
///--------------------------------------


/**
 *  List all attributes from the Object
 */
- (void)listAttributes;



# pragma mark - Deprecated

///--------------------------------------
/// @name Deprecated
///--------------------------------------

/**
 * Retrieves all 'MASGroup' objects from the Range passed as parameter.
 *
 * @param pageRange The Range to be used in the pagination
 * @param completion Completion block with either the NSArray of MASGroup object or the Error message
 */
+ (void)getAllGroups:(NSRange)pageRange
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves a 'MASGroup' object with all the data from the cloud based in the ObjectId provided.
 *
 * @param objectId The ObjectId used to locate the User in the cloud storage.
   @param completion Completion block with either the MASGroup object or the Error message
 */
+ (void)getGroupByObjectId:(NSString *)objectId
    completion:(void (^)(MASGroup *group, NSError *error))completion;


/**
 * Retrieves all 'MASGroup' objects that matches the GroupName passed as parameter. It uses a default 
 * of 10 for the itemsPerPage for the pagination.
 *
 * @param groupName GroupName to be used in the search
 * @param pageRange The Range to be used in the pagination
 * @param completion Completion block with either the NSArray of MASGroup object or the Error message
 */
+ (void)getGroupsWithName:(NSString *)groupName
    range:(NSRange)pageRange
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASGroup' objects that matches the Owner passed as parameter. It uses a default of 10 
 * for the itemsPerPage for the pagination.
 *
 * @param owner Owner to be used in the search
 * @param pageRange The Range to be used in the pagination
 * @param completion Completion block with either the NSArray of MASGroup object or the Error message
 */
+ (void)getGroupsWithOwner:(NSString *)owner
    range:(NSRange)pageRange
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASGroup' objects that matches the User member passed as parameter. It uses a default
 * of 10 for the itemsPerPage for the pagination.
 *
 * @param user User to be used in the search
 * @param pageRange The Range to be used in the pagination
 * @param completion Completion block with either the NSArray of MASGroup object or the Error message
 */
+ (void)getGroupsWithMember:(MASUser *)user
    range:(NSRange)pageRange
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASGroup' objects that matches the SCIM Filter passed as parameter
 *
 * @param filter SCIM Filter to be used in the search
 * @param pageRange The Range to be used in the pagination
 * @param completion Completion block with either the NSArray of MASGroup object or the Error message
 */
+ (void)getGroupsUsingFilter:(NSString *)filter
    range:(NSRange)pageRange
    completion:(void (^)(NSArray *groupList, NSError *error, NSUInteger totalResults))completion;

@end
