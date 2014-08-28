//
// Created by Dmitry Sobolev on 27/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAccount.h"

@class XBAccount;

@protocol XBConnector <NSObject>

@property (nonatomic, weak) XBAccount* account;

- (BOOL)isLoggedIn;

- (void)loginWithCompletion:(void (^)(NSError *error))completionHandler;

- (void)logoutWithCompletion:(void(^)(NSError *error))completionHandler;

- (void)setNewStatus:(XBAccountStatus)status;

@end