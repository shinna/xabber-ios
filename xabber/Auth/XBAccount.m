//
// Created by Dmitry Sobolev on 22/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>
#import "XBAccount.h"
#import "XBXMPPCoreDataAccount.h"


static NSString *const XBKeychainServiceName = @"xabberService";

@interface XBAccount(){
}
@end

@implementation XBAccount

- (instancetype)initWithAccountID:(NSString *)accountID {
    self = [super init];
    if (self) {
        self.accountID = accountID;
        [self setDefaults];
        _isNew = YES;
        _isDeleted = NO;
    }

    return self;
}

+ (instancetype)accountWithAccountID:(NSString *)accountID {
    return [[self alloc] initWithAccountID:accountID];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaults];
        _isNew = YES;
        _isDeleted = NO;
    }

    return self;
}

+ (instancetype)account {
    return [[self alloc] init];
}

- (instancetype)initWithCoreDataAccount:(XBXMPPCoreDataAccount *)account {
    self = [super init];
    if (self) {
        [self loadFromCoreDataAccount:account];
        [self loadPasswordWithAccountID:self.accountID];
        _isNew = NO;
        _isDeleted = NO;
    }

    return self;
}

+ (instancetype)accountWithCoreDataAccount:(XBXMPPCoreDataAccount *)account {
    return [[self alloc] initWithCoreDataAccount:account];
}

#pragma mark Save

- (BOOL)save {
    if(![self saveCoreData]){
        return NO;
    }

    if(![self savePassword]){
        return NO;
    }

    _isNew = NO;

    return YES;
}

- (BOOL)saveCoreData {
    __block XBXMPPCoreDataAccount *account;

    if (_isNew) {
        account = [XBXMPPCoreDataAccount MR_findFirstByAttribute:@"accountID" withValue:self.accountID];

        if (account) {
            return NO;
        }
    }

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        account = [XBXMPPCoreDataAccount MR_importFromObject:self.dumpToDictionary inContext:localContext];
    }];

    return account != nil;
}

- (BOOL)savePassword {
    if (!self.password) {
        NSString *oldPassword = [SSKeychain passwordForService:XBKeychainServiceName account:self.accountID];

        if (!oldPassword) {
            return YES;
        }

        return [SSKeychain deletePasswordForService:XBKeychainServiceName account:self.accountID];
    }

    return [SSKeychain setPassword:self.password forService:XBKeychainServiceName account:self.accountID];
}

#pragma mark Load

- (BOOL)loadFromCoreDataAccount:(XBXMPPCoreDataAccount *)account {
    if (!account) {
        return NO;
    }

    self.accountID = account.accountID;
    self.autoLogin = [account.autoLogin boolValue];
    self.status = (XBAccountStatus) [account.status integerValue];
    self.host = account.host;
    self.port = (int16_t) [account.port integerValue];

    return YES;
}

- (BOOL)loadPasswordWithAccountID:(NSString *)accountID {
    if (!accountID) {
        return NO;
    }

    self.password = [SSKeychain passwordForService:XBKeychainServiceName account:accountID];

    return self.password != nil;
}

#pragma mark Delete

- (BOOL)delete {
    if (![self deleteCoreData]) {
        return NO;
    }

    if (![self deletePassword]) {
        return NO;
    }

    _isDeleted = YES;

    return YES;
}

- (BOOL)deleteCoreData {
    XBXMPPCoreDataAccount *account = [XBXMPPCoreDataAccount MR_findFirstByAttribute:@"accountID" withValue:self.accountID];

    if (account) {
        return [account MR_deleteEntity];
    }

    return NO;
}

- (BOOL)deletePassword {
    if (self.password) {
        return [SSKeychain deletePasswordForService:XBKeychainServiceName account:self.accountID];
    }

    return YES;
}

#pragma mark Private

- (void)setDefaults {
    self.status = XBAccountStatusAvailable;
    self.autoLogin = YES;
    self.port = 5222;
}

- (NSDictionary *)dumpToDictionary {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:5];

    if (self.accountID) {
        data[@"accountID"] = self.accountID;
    }

    if (self.autoLogin) {
        data[@"autoLogin"] = @(self.autoLogin);
    }

    if (self.status) {
        data[@"status"] = @(self.status);
    }

    if (self.host) {
        data[@"host"] = self.host;
    }

    if (self.port) {
        data[@"port"] = @(self.port);
    }

    return data;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToAccount:other];
}

- (BOOL)isEqualToAccount:(XBAccount *)account {
    if (self == account)
        return YES;
    if (account == nil)
        return NO;
    if (self.accountID != account.accountID && ![self.accountID isEqualToString:account.accountID])
        return NO;
    if (self.password != account.password && ![self.password isEqualToString:account.password])
        return NO;
    if (self.autoLogin != account.autoLogin)
        return NO;
    if (self.status != account.status)
        return NO;
    if (self.host != account.host && ![self.host isEqualToString:account.host])
        return NO;
    if (self.port != account.port)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.accountID hash];
    hash = hash * 31u + [self.password hash];
    hash = hash * 31u + self.autoLogin;
    hash = hash * 31u + (NSUInteger) self.status;
    hash = hash * 31u + [self.host hash];
    hash = hash * 31u + self.port;
    return hash;
}


@end