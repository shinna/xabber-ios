//
// Created by Dmitry Sobolev on 18/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XBXMPPCoreDataAccount;


@interface XBAccountManager : NSObject

+ (XBAccountManager *)sharedInstance;

- (void)addAccount:(NSDictionary *)data;

- (void)deleteAccountWithID:(NSString *)accountID;

- (NSArray *)accounts;

- (XBXMPPCoreDataAccount *)findAccountByID:(NSString *)accountID;
@end