//
// Created by Dmitry Sobolev on 22/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XBXMPPCoreDataAccount;

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

- (instancetype)initWithAccountID:(NSString *)accountID;

- (instancetype)initWithCoreDataAccount:(XBXMPPCoreDataAccount *)account;

+ (instancetype)accountWithAccountID:(NSString *)accountID;

+ (instancetype)account;

+ (instancetype)accountWithCoreDataAccount:(XBXMPPCoreDataAccount *)account;

- (BOOL)save;

#pragma mark Equality

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToAccount:(XBAccount *)account;

- (NSUInteger)hash;

@end