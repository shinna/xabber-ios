//
// Created by Dmitry Sobolev on 18/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XBXMPPCoreDataAccount;
@class XBAccount;


@interface XBAccountManager : NSObject

+ (XBAccountManager *)sharedInstance;

- (void)addAccount:(XBAccount *)account;

- (void)deleteAccountWithID:(NSString *)accountID;

- (void)deleteAccount:(XBAccount *)account;

- (NSArray *)accounts;

- (XBAccount *)findAccountByID:(NSString *)accountID;
@end