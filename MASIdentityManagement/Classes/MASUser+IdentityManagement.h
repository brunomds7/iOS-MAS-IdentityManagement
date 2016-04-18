//
//  MASUser+IdentityManagement.h
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-07-23.
//  Copyright (c) 2015 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>

#import "MASFilter.h"
#import "MASFilteredRequest.h"


/**
 * The supported SCIM attribute options.
 */
typedef NS_OPTIONS(NSInteger, MASUserAttributes)
{
    MASUserAttributeAll = 1 << 0,
    MASUserAttributeName = 1 << 1,
    MASUserAttributeUserName = 1 << 2,
    MASUserAttributeActive = 1 << 3,
    MASUserAttributeAddresses = 1 << 4,
    MASUserAttributeEmailAddresses = 1 << 5,
    MASUserAttributeGroups = 1 << 6,
    MASUserAttributePhoneNumbers = 1 << 7,
    MASUserAttributePhotos = 1 << 8
};


/**
 *  This category enables Identity Management feature to the authenticated user
 */
@interface MASUser (IdentityManagement)



# pragma mark - Basic User Retrieval

///--------------------------------------
/// @name Basic User Retrieval
///--------------------------------------


/**
 * Retrieves all 'MASUser' objects.  Note, this version has no paging or filtering at all.  You will
 * receive not only all of the 'MASUser' objects, but all their fields as well.
 *
 * @param completion Completion block with either the array of 'MASUser' or 'NSError'.
 */
+ (void)getAllUsersWithCompletion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASUser' objects with various sorting, paging and included/excluded attribute options.
 *
 * @param sortByAttribute An attribute of the 'MASUser' that can be used to sort the results. (optional)
 * @param sortOrder The 'MASFilteringRequestSortOrder' direction of the results.  Valid values are
 *     'MASFilteringRequestSortOrderAscending' and 'MASFilteringRequestSortOrderDescending'.
 * @param pageRange 'NSRange' containing pagination values.
 * @param includedAttributes 'NSArray' of 'NSString' attribute names to include in the results for each object.
 *     Note, if there attribute names included the excluded attributes are ignored. (optional)
 * @param excludedAttributes 'NSArray' of 'NSString' attribute names to exclude from the results for each object.
 *     Note, these will only take effect if there are no 'includedAttributes'. (optional)
 * @param completion Completion block with either the array of 'MASUser' objects or NSError.
 */
+ (void)getAllUsersSortedByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASUser' objects that matches the UserName passed as parameter. It is a complete match.  Not a
 * partial match. It uses a default of 10 for the itemsPerPage for the pagination.
 *
 * @param value The 'NSString' full user name to match.
 * @param sortByAttribute An attribute of the 'MASUser' that can be used to sort the results. (optional)
 * @param sortOrder The 'MASFilteringRequestSortOrder' direction of the results.  Valid values are
 *     'MASFilteringRequestSortOrderAscending' and 'MASFilteringRequestSortOrderDescending'.
 * @param pageRange 'NSRange' containing pagination values.
 * @param includedAttributes 'NSArray' of 'NSString' attribute names to include in the results for each object.
 *     Note, if there attribute names included the excluded attributes are ignored. (optional)
 * @param excludedAttributes 'NSArray' of 'NSString' attribute names to exclude from the results for each object.
 *     Note, these will only take effect if there are no 'includedAttributes'. (optional)
 * @param completion Completion block with either the NSArray of MASUser object or the Error message.
 */
+ (void)getAllUsersWithUsernameContaining:(NSString *)value
    sortByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves a 'MASUser' object with all the data from the cloud based in the ObjectId provided.
 *
 * @param objectId The ObjectId used to locate the User in the cloud storage.
 * @param completion Completion block with either the MASUser object or the Error message
 */
+ (void)getUserByObjectId:(NSString *)objectId
    completion:(void (^)(MASUser *user, NSError *error))completion;


/**
 * Retrieves a 'MASUser' object with all the data from the cloud based in the ObjectId provided.
 *
 * @param objectId The ObjectId used to locate the User in the cloud storage.
 * @param includedAttributes 'NSArray' of 'NSString' attribute names to include in the results for each object.
 *     Note, if there attribute names included the excluded attributes are ignored. (optional)
 * @param excludedAttributes 'NSArray' of 'NSString' attribute names to exclude from the results for each object.
 *     Note, these will only take effect if there are no 'includedAttributes'. (optional)
 * @param completion Completion block with either the MASUser object or the Error message
 */
+ (void)getUserByObjectId:(NSString *)objectId
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(MASUser *user, NSError *error))completion;


/**
 * Retrieves a 'MASUser' object by its fully equal user name.
 *
 * @param objectId The ObjectId used to locate the User in the cloud storage.
 * @param includedAttributes 'NSArray' of 'NSString' attribute names to include in the results for each object.
 *     Note, if there attribute names included the excluded attributes are ignored. (optional)
 * @param excludedAttributes 'NSArray' of 'NSString' attribute names to exclude from the results for each object.
 *     Note, these will only take effect if there are no 'includedAttributes'. (optional)
 * @param completion Completion block with either the MASUser object or the Error message
 */
+ (void)getUserByUserName:(NSString *)userName
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(MASUser *user, NSError *error))completion;



# pragma mark - Filtered Request User Retrieval

///---------------------------------------------
/// @name Custom Filtered Request User Retrieval
///---------------------------------------------


/**
 * Retrieves 'MASUser' objects that matches the 'MASFilteredRequest'.
 *
 * @param filter The 'MASFilteredRequest; to filter results.
 * @param completion Completion block with either the array of 'MASUser' objects or the 'NSError'.
 */
+ (void)getUsersByFilteredRequest:(MASFilteredRequest *)filteredRequest
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;



# pragma mark - Advanced Filtering User Retrieval

///----------------------------------------
/// @name Advanced Filtering User Retrieval
///----------------------------------------


/**
 * Retrieves 'MASUser' objects that matches the custom built filter expression and additional options.
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
 * @param completion Completion block with either the array of 'MASUser' objects or NSError.
 */
+ (void)getUsersByFilterExpression:(NSString *)filterExpression
    sortByAttribute:(NSString *)sortByAttribute
    sortOrder:(MASFilteredRequestSortOrder)sortOrder
    pageRange:(NSRange)pageRange
    includedAttributes:(NSArray *)includedAttributes
    excludedAttributes:(NSArray *)excludedAttributes
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;



# pragma mark - User Images

///--------------------------------------
/// @name User Images
///--------------------------------------


/**
 * Retrieve the thumbnail 'UIImage' of the 'MASUser'.
 *
 * @param completion Completion block with either the retrieved 'UIImage' or 'NSError'.
 */
- (void)getThumbnailImageWithCompletion:(void (^)(UIImage *image, NSError *error))completion;



# pragma mark - Instance Methods

///--------------------------------------
/// @name Instance Methods
///--------------------------------------


/**
 *  Returns the value associated with a given key.
 *
 *  @param key The given identifying key for which to return the corresponding value.
 *
 *  @return The value associated with a given key.
 */
- (id)objectForKey:(id)key;



/**
 *  Sets the object associated with a given key.
 *
 *  @param object The object for `key`. A strong reference to the object is maintaned by MASObject.
 *                Raises an `NSInvalidArgumentException` if `object` is `nil`.
 *                If you need to represent a `nil` value - use `NSNull`.
 *
 *  @param key    The key for `object`. Raises an `NSInvalidArgumentException` if `key` is `nil`.
 */
- (void)setObject:(id)object forKey:(id <NSCopying>)key;



/**
 *  Returns the value associated with a given key.
 *
 *  @discussion This method enables usage of literal syntax on `MASObject`. E.g. `NSString *value = object[@"key"];`
 *
 *  @param key The key for which to return the corresponding value.
 *
 *  @return The value associated with a given key.
 */
- (id)objectForKeyedSubscript:(id)key;



/**
 *  Returns the value associated with a given key.
 *
 *  @discussion This method enables usage of literal syntax on `MASObject`. E.g. `object[@"key"] = @"value";`
 *
 *  @param object The object for `key`. A strong reference to the object is maintaned by PFObject.
 *                Raises an `NSInvalidArgumentException` if `object` is `nil`.
 *                If you need to represent a `nil` value - use `NSNull`.
 *
 *  @param key    key The key for `object`. Raises an `NSInvalidArgumentException` if `key` is `nil`.
 */
- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;



# pragma mark - Print Attributes

///--------------------------------------
/// @name Print Attributes
///--------------------------------------


/**
 *  List all attributes from the Object.
 */
- (void)listAttributes;



# pragma mark - Deprecated

///--------------------------------------
/// @name Deprecated
///--------------------------------------

/**
 * Retrieves all 'MASUser' objects with pagination determined by the 'NSRange' parameter.  You will
 * receive not only all of the 'MASUser' objects, but all their fields as well.
 *
 * @param pageRange 'NSRange' containing pagination values.
 * @param completion Completion block with either the array of 'MASUser' objects or NSError.
 */
+ (void)getAllUsers:(NSRange)pageRange
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves all 'MASUser' objects that contains the UserName passed as parameter. It uses a default
 * of 10 for the itemsPerPage for the pagination.
 *
 *
 * @param userName The 'NSString' username to be used in the search.
 * @param pageRange The Range to be used in the pagination.
 * @param completion Completion block with either the NSArray of MASUser object or the Error message
 */
+ (void)getUsersWithUsername:(NSString *)userName
    range:(NSRange)pageRange
    completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;


/**
 * Retrieves a 'MASUser' object with all the data from the cloud based in the ObjectId provided.
 *
 * @param objectId The ObjectId used to locate the User in the cloud storage.
 * @param MASUserAttributes The requested attribute options.
 * @param completion Completion block with either the MASUser object or the Error message
 */
+ (void)getUserByObjectId:(NSString *)objectId
    attributes:(MASUserAttributes)attributes
    completion:(void (^)(MASUser *user, NSError *error))completion;

@end

