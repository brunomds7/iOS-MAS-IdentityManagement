//
//  MASFilter.m
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASFilter.h"


@interface MASFilter ()

# pragma mark - Properties

@property (nonatomic, copy) NSString *expression;

@end


@implementation MASFilter


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
    return [NSString stringWithFormat:@"(%@) expression: %@", self.class, self.expression];
}


# pragma mark - Private

+ (NSString *)baseExpressionFromFilter:(MASFilter *)filter
{
    NSString *expression = [filter.expression mutableCopy];
    
    //
    // Remove the filter prefix with empty character
    //
    expression = [expression stringByReplacingOccurrencesOfString:MASIdMgmtFilterPrefix
        withString:MASIdMgmtNoSpace];
    
    return expression;
}


# pragma mark - Filters

+ (MASFilter *)filterByAttribute:(NSString *)attribute contains:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorContains andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute endsWith:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorEndsWith andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute equalTo:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorEqualTo andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute greaterThan:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorGreaterThan andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute greaterThanOrEqualTo:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorGreaterThanOrEqualTo andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute lessThan:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorLessThan andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute lessThanOrEqualTo:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorLessThanOrEqualTo andValue:value];
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute notEqualTo:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorNotEqualTo andValue:value];
}


+ (MASFilter *)filterByAttributePresent:(NSString *)attribute;
{
    //
    // None of these are optional
    //
    NSParameterAssert(attribute);

    // todo
    return nil;
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute startsWith:(NSString *)value
{
    return [self filterByAttribute:attribute withAttributeOperator:MASFilterAttributeOperatorStartsWith andValue:value];
}


# pragma mark - Advanced Filtering

- (NSString *)asStringFilterExpression
{
    return self.expression;
}


+ (MASFilter *)filterByAttribute:(NSString *)attribute withAttributeOperator:(MASFilterAttributeOperator)attributeOperator andValue:(NSString *)value
{
    DLog(@"\n\ncalled with attribute: %@, operator: %@ and value: %@\n\n",
        attribute, [MASIdentityManagementConstants attributeOperatorToString:attributeOperator], value);
    
    //
    // None of these are optional
    //
    NSParameterAssert(attribute);
    NSParameterAssert(value);
    
    NSMutableString *expression = [NSMutableString stringWithString:MASIdMgmtFilterPrefix];
    
    [expression appendString:attribute];
    [expression appendString:MASIdMgmtEmptySpace];
    [expression appendString:[MASIdentityManagementConstants attributeOperatorToString:attributeOperator]];
    [expression appendString:MASIdMgmtEmptySpace];
    [expression appendFormat:@"\"%@\"", value];
    
    MASFilter *filter = [[MASFilter alloc] initPrivate];
    filter.expression = expression;
    
    return filter;
}


+ (MASFilter *)fromStringFilterExpression:(NSString *)expression
{
    //
    // None of these are optional
    //
    NSParameterAssert(expression);
    
    MASFilter *filter = [[MASFilter alloc] initPrivate];
    filter.expression = expression;
    
    return filter;
}

@end
