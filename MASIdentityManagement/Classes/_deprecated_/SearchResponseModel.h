//
//  SearchResponseModel.h
//  MASIdentityManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;


/**
 *
 */
@interface SearchResponseModel : NSObject

# pragma mark - Properties

@property (nonatomic, assign) NSInteger totalResults;
@property (nonatomic, assign) NSUInteger currentPageStart;
@property (nonatomic, assign) NSUInteger nextPageStart;
@property (nonatomic) NSArray *results;

@end
