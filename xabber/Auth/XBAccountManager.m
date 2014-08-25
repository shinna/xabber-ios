//
// Created by Dmitry Sobolev on 18/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import "XBAccountManager.h"
#import "XBXMPPCoreDataAccount.h"
#import "XBXMPPCoreDataAccount.h"
#import "XBAccount.h"

@interface XBAccountManager() {
    NSMutableArray *_accounts;
}
@end

@implementation XBAccountManager
- (id)init {
    self = [super init];
    if (self) {
        _accounts = [NSMutableArray array];
        [self loadCachedAccounts];
    }

    return self;
}


+ (XBAccountManager *)sharedInstance {
    static XBAccountManager *sharedManager = nil;
    static dispatch_once_t once_token;

    dispatch_once(&once_token, ^{
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

- (void)addAccount:(XBAccount *)account {
    if (account && !account.isNew) {
        [_accounts addObject:account];
    }
}

- (void)deleteAccountWithID:(NSString *)accountID {
    XBAccount *account = [self findAccountByID:accountID];

    [account delete];

    [_accounts removeObject:account];
}

- (void)deleteAccount:(XBAccount *)account {
    if ([_accounts containsObject:account]) {
        [account delete];
        [_accounts removeObject:account];
    }
}

- (NSArray *)accounts {
    return _accounts;
}

- (XBAccount *)findAccountByID:(NSString *)accountID {
    return [[_accounts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(XBAccount *account, NSDictionary *bindings){
        return [account.accountID isEqualToString:accountID];
    }]] firstObject];
}

#pragma mark Private

- (void)loadCachedAccounts {
    NSArray *coreDataAccounts = [XBXMPPCoreDataAccount MR_findAll];

    [coreDataAccounts enumerateObjectsUsingBlock:^(XBXMPPCoreDataAccount *coreDataAccount, NSUInteger idx, BOOL *stop){
        [self addAccount:[XBAccount accountWithCoreDataAccount:coreDataAccount]];
    }];
}

@end