//
// Created by Dmitry Sobolev on 22/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XBXMPPCoreDataAccount;
@protocol XBAccountDelegate;
@protocol XBConnector;


typedef enum {
    XBAccountStatusAvailable,
    XBAccountStatusChat,
    XBAccountStatusAway,
    XBAccountStatusXA,
    XBAccountStatusDnD
} XBAccountStatus;

@interface XBAccount : NSObject

@property (nonatomic, strong) NSString *accountID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL autoLogin;
@property (nonatomic, assign) XBAccountStatus status;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) int16_t port;

@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, readonly) BOOL isDeleted;

@property (nonatomic, strong) id<XBAccountDelegate> delegate;

- (instancetype)initWithConnector:(id <XBConnector>)connector coreDataAccount:(XBXMPPCoreDataAccount *)account;

- (instancetype)initWithConnector:(id <XBConnector>)connector;

+ (instancetype)accountWithConnector:(id <XBConnector>)connector;

+ (instancetype)accountWithConnector:(id <XBConnector>)connector coreDataAccount:(XBXMPPCoreDataAccount *)account;

- (BOOL)save;

- (BOOL)delete;

- (void)login;

- (void)logout;

- (BOOL)isLoggedIn;

#pragma mark Equality

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToAccount:(XBAccount *)account;

- (NSUInteger)hash;

@end


@protocol XBAccountDelegate <NSObject>

- (void)accountWillLogin:(XBAccount *)account;

- (void)accountDidLoginSuccessfully:(XBAccount *)account;

- (void)account:(XBAccount *)account didNotLoginWithError:(NSError *)error;

- (void)accountWillLogout:(XBAccount *)account;

- (void)accountDidLogoutSuccessfully:(XBAccount *)account;

- (void)account:(XBAccount *)account didNotLogoutWithError:(NSError *)error;

@end