//
//  MASIdentityManagementTests.m
//  MASIdentityManagementTests
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MASIdentityManagement/MASIdentityManagement.h>
#import "MASUser+IdentityManagement.h"
#import <MASFoundation/MASFoundation.h>

static NSString *sampleUserObjectId     = @"KmwcB2UlSECduF1M-dfECA==";
static NSString *sampleDeviceObjectId   = @"a6adb5912420041ef353d70fd39cdcf7";
static NSString *sampleUserName         = @"r";
static NSString *sampleFilter           = @"userName co \"nlu\"";

#define kMatDemoUser    @"jkirk"
#define kMatDemoPwd     @"CAapiGW"

@interface MASIdentityManagementTests : XCTestCase

@end

@implementation MASIdentityManagementTests

/**
 *  Initial Setup to be used during tests
 *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
 */
- (void)setUp
{
    [super setUp];
}


/**
 *  TearDown any object
 */
- (void)tearDown
{
    [super tearDown];
}


/**
 *  Performance sample test
 */
- (void)PerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


//#pragma mark - User Category methods
//
///**
// *  Test the GetAllUsers method
// *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
// * /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents
// */
//- (void)testGetAllUsers
//{
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//    
//    [MAS resetWithCompletion:^(BOOL completion, NSError *error) {
//        [MAS start:^(BOOL completion, NSError *error) {
//            
//            [MAS registerDeviceWithUserName:kMatDemoUser password:kMatDemoPwd completion:^(BOOL completion, NSError *error) {
//                
//                XCTAssertTrue(completion,@"Pass");
//                
//                NSRange newRange = NSMakeRange(1, 6);
//                
//                [MASUser getAllUsers:newRange completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//                    
//                    XCTAssertTrue(userList,@"List of Users retrieved successfully");
//                    
//                    [expectation fulfill];
//                }];
//            }];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:20.0 handler:nil];
//}
//
//
///**
// *  Test the GetUsersWithUserName method
// *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
// * /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents
// */
//- (void)testGetUsersWithUserName
//{
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//    
//    [MAS resetWithCompletion:^(BOOL completion, NSError *error) {
//        [MAS start:^(BOOL completion, NSError *error) {
//            
//            [MAS registerDeviceWithUserName:kMatDemoUser password:kMatDemoPwd completion:^(BOOL completion, NSError *error) {
//                
//                XCTAssertTrue(completion,@"Pass");
//                
//                NSRange newRange = NSMakeRange(1, 5);
//                
//                [MASUser getUsersWithUsername:sampleUserName range:newRange completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//
//                    XCTAssertTrue(userList,@"List of Users retrieved successfully");
//                    
//                    [expectation fulfill];
//                }];
//            }];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:20.0 handler:nil];
//}
//
//
///**
// *  Test the GetUserByObjectId method
// *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
// */
//- (void)testGetUserByObjectId
//{
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//    
//        [MAS start:^(BOOL completion, NSError *error) {
//            
//            [MAS registerDeviceWithUserName:kMatDemoUser password:kMatDemoPwd completion:^(BOOL completion, NSError *error) {
//            
//                XCTAssertTrue(completion,@"Pass");
//                
//                [MASUser getUserByObjectId:sampleUserObjectId completion:^(MASUser *user, NSError *error) {
//                    
//                    XCTAssertTrue(user,@"User object retrieved successfully");
//                    
//                    [expectation fulfill];
//                }];
//            }];
//        }];
//    
//    [self waitForExpectationsWithTimeout:20.0 handler:nil];
//}
//
//
//
///**
// *  Test the GetUsersUsingFilter method
// *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
// */
//- (void)testGetUsersUsingFilter
//{
//    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"asynchronous request"];
//    
//    [MAS start:^(BOOL completion, NSError *error) {
//        
//        [MAS registerDeviceWithUserName:kMatDemoUser password:kMatDemoPwd completion:^(BOOL completion, NSError *error) {
//            
//            XCTAssertTrue(completion,@"Pass");
//            
//            NSRange newRange = NSMakeRange(1, 5);
//
//            [MASUser getUsersUsingFilter:sampleFilter range:newRange completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {
//                
//                XCTAssertTrue(userList,@"List of Users retrieved successfully");
//                
//                [expectation fulfill];
//            }];
//        }];
//    }];
//    
//    [self waitForExpectationsWithTimeout:20.0 handler:nil];
//}
//
//
//
//
//#pragma mark - Device Category methods
//
///**
// *  Test the GetDeviceByObjectId method
// *  NOTE: A copy of the msso_config.json file must be copied into the xcode bundle in order to run [MAS start]
// */
//- (void)GetDeviceByObjectId
//{
//    //TBD
//}

@end
