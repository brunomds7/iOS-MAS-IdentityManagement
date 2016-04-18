# MASIdentityManagement

[![Build Status](https://travis-ci.org/mobile-web-messaging/MQTTKit.svg)](https://thesource.l7tech.com/thesource/Matterhorn/client-sdk/ios/trunk/Connecta)

MASIdentityManagement is responsible for managing identities in the MAS SDK. It extends the MAS object with new properties and methods. The underlying protocol is SCIM.

This framework is part of the  **iOS CA Mobile App Services SDK.** Other frameworks in the SDK include:

- [MASFoundation](https://github-isl-01.ca.com/MAS/iOS-MAS-Foundation)
- [MASConnecta](https://github-isl-01.ca.com/MAS/iOS-MAS-Connecta)
- [MASStorage](https://github-isl-01.ca.com/MAS/iOS-MAS-Storage)

## Install By Manually Importing the Framework

1. Open your project in Xcode.
2. On your ```Project target```, go to the ```General``` tab and import the framework in the ```Embedded Binaries``` section.

## Usage

Import the `MASIdentityManagement.h` header file to any class that you want to use or to the `.pch` file if your project has one.

```
#import <MASIdentityManagement/MASIdentityManagement.h>
```


### Managing Users
Paging is available to retrieve user data.

######+ (void)getUsersWithUsername:(NSString *)userName range:(NSRange)pageRange completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;
```
//Retrieve an array of MASUser objects that matches the given userName
[MASUser getUsersWithUsername:sampleUserName range:newRange completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {

	//your code here            
}];
```

######+ (void)getUserByObjectId:(NSString *)objectId completion:(void (^)(MASUser *user, NSError *error))completion
```
//Get the user profile from SCIM that matches the given objectId
[MASUser getUserByObjectId:sampleUserObjectId completion:^(MASUser *user, NSError *error) {
	
	//your code here            
}];
```

######+ (void)getUsersUsingFilter:(NSString *)filter range:(NSRange)pageRange completion:(void (^)(NSArray *userList, NSError *error, NSUInteger totalResults))completion;
```
//Retrieve an array of MASUser objects that matches the given SCIM filter
[MASUser getUsersUsingFilter:sampleFilter range:newRange completion:^(NSArray *userList, NSError *error, NSUInteger totalResults) {

	//your code here            
}];
```
