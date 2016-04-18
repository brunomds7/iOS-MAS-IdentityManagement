//
//  SearchResponseModel.h
//  MASIdentityManagement
//
//  Created by Luis Sanches on 2015-10-12.
//  Copyright © 2015 CA Technologies. All rights reserved.
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
