//
//  MASIdentityManagementConstants.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIdentityManagementConstants.h"


@implementation MASIdentityManagementConstants


# pragma mark - Attribute & Logical Operators

+ (NSString *)attributeOperatorToString:(MASFilterAttributeOperator)attributeOperator
{
    //
    // Detect operator and respond appropriately
    //
    switch(attributeOperator)
    {
        // Contains
        case MASFilterAttributeOperatorContains : return MASIdMgmtAttributeOperatorContains;
    
        // EndsWith
        case MASFilterAttributeOperatorEndsWith: return MASIdMgmtAttributeOperatorEndsWith;
    
        // GreaterThan
        case MASFilterAttributeOperatorGreaterThan: return MASIdMgmtAttributeOperatorGreaterThan;
    
        // GreaterThanOrEqualTo
        case MASFilterAttributeOperatorGreaterThanOrEqualTo: return MASIdMgmtAttributeOperatorGreaterThanOrEqualTo;
        
        // LessThan
        case MASFilterAttributeOperatorLessThan: return MASIdMgmtAttributeOperatorLessThan;
    
        // LessThanOrEqualTo
        case MASFilterAttributeOperatorLessThanOrEqualTo: return MASIdMgmtAttributeOperatorLessThanOrEqualTo;
    
        // NotEqualTo
        case MASFilterAttributeOperatorNotEqualTo: return MASIdMgmtAttributeOperatorNotEqualTo;
    
        // Present
        case MASFilterAttributeOperatorPresent: return MASIdMgmtAttributeOperatorPresent;
    
        // StartsWith
        case MASFilterAttributeOperatorStartsWith: return MASIdMgmtAttributeOperatorStartsWith;
    
        // Default EqualTo
        default: return MASIdMgmtAttributeOperatorEqualTo;
    }
}


+ (NSString *)logicalOperatorToString:(MASFilterLogicalOperator)logicalOperator
{
    //
    // Detect operator and respond appropriately
    //
    switch(logicalOperator)
    {
        // Not
        case MASFilterLogicalOperatorNot : return MASIdMgmtLogicalOperatorNot;
        
        // Or
        case MASFilterLogicalOperatorOr : return MASIdMgmtLogicalOperatorOr;
        
        // Default And
        default : return MASIdMgmtLogicalOperatorAnd;
    }
}


# pragma mark - Sorting

///--------------------------------------
/// @name Sorting
///--------------------------------------

/**
 * Retrieve the 'NSString' value of a 'MASFilteredRequestSortOrder'.
 *
 * @param sortOrder The 'MASFilteredRequestSortOrder'.
 * @return 'NSString'.
 */
+ (NSString *)lsortOrderToString:(MASFilteredRequestSortOrder)sortOrder
{
    //
    // Detect sortOrder and respond appropriately
    //
    switch(sortOrder)
    {
        // Descending
        case MASFilteredRequestSortOrderDescending : return MASIdMgmtSortOrderDescending;
        
        // Default Ascending
        default : return MASIdMgmtSortOrderAscending;
    }
}
    
@end
