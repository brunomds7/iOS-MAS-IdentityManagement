//
//  MASFilteredRequest.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASFilteredRequest.h"

#import "MASFilter.h"


@implementation MASFilteredRequest


# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) sortByAttribute: %@, sortOrder: %@, paginationRange: (starting location: %ld, length: %ld) and filter: %@",
            self.class, self.sortByAttribute, (self.sortOrder == MASFilteredRequestSortOrderAscending ?
                                               MASIdMgmtSortOrderAscending : MASIdMgmtSortOrderDescending),
        (unsigned long)self.paginationRange.location, (unsigned long)self.paginationRange.length, [self.filter debugDescription]];
}


# pragma mark - Filtered Requests

+ (MASFilteredRequest *)filteredRequest
{
    return [[MASFilteredRequest alloc] initPrivate];
}


# pragma mark - Advanced Filtered Requests

- (NSString *)asStringQueryPath
{
    //
    // Initial request path
    //
    NSMutableString *filterRequestPath = [NSMutableString new];
    
    //
    // Filter
    //
    if(self.filter)
    {
        //
        // If ampersand OR question mark needed
        //
        [filterRequestPath appendString:(filterRequestPath.length > 1 ? MASIdMgmtAmpersand : MASIdMgmtQuestionMark)];
        
        //
        // Filter
        //
        [filterRequestPath appendString:[self.filter asStringFilterExpression]];
    }
    
    //
    // Sort
    //
    if(self.sortByAttribute)
    {
        //
        // If ampersand OR question mark needed
        //
        [filterRequestPath appendString:(filterRequestPath.length > 1 ? MASIdMgmtAmpersand : MASIdMgmtQuestionMark)];
           
        //
        // SortBy
        //
        [filterRequestPath appendFormat:@"sortBy=%@", self.sortByAttribute];
        
        //
        // Sort Order
        //
        [filterRequestPath appendFormat:@"&sortOrder=%@",(self.sortOrder == MASFilteredRequestSortOrderAscending ? MASIdMgmtSortOrderAscending : MASIdMgmtSortOrderDescending)];
    }
    
    
    //
    // Pagination
    //
    if(self.paginationRange.length != NSNotFound && self.paginationRange.length != 0)
    {
        //
        // If ampersand OR question mark needed
        //
        [filterRequestPath appendString:(filterRequestPath.length > 1 ? MASIdMgmtAmpersand : MASIdMgmtQuestionMark)];
        
        //
        // StartIndex and Count
        //
        [filterRequestPath appendFormat:@"startIndex=%lu&count=%lu",
            (unsigned long)self.paginationRange.location,
            (unsigned long)self.paginationRange.length];
    }
    
    //
    // Included Attributes
    //
    if(self.includedAttributes.count > 0)
    {
        //
        // If ampersand OR question mark needed
        //
        [filterRequestPath appendString:(filterRequestPath.length > 1 ? MASIdMgmtAmpersand : MASIdMgmtQuestionMark)];
        
        //
        // Included Attributes in comma seperated NSString format
        //
        [filterRequestPath appendFormat:@"attributes=%@", [self.includedAttributes componentsJoinedByString:@","]];
    }
    
    //
    // Excluded Attributes
    //
    if(self.excludedAttributes.count > 0)
    {
        //
        // If ampersand OR question mark needed
        //
        [filterRequestPath appendString:(filterRequestPath.length > 1 ? MASIdMgmtAmpersand : MASIdMgmtQuestionMark)];
        
        //
        // Excluded Attributes in comma seperated NSString format
        //
        [filterRequestPath appendFormat:@"excludedAttributes=%@", [self.excludedAttributes componentsJoinedByString:@","]];
    }
    
    return filterRequestPath;
}


+ (MASFilteredRequest *)fromStringQueryPath:(NSString *)queryPath
{
    // todo: parse the query path to a MASFilteredRequest
    
    return [MASFilteredRequest filteredRequest];
}

@end
