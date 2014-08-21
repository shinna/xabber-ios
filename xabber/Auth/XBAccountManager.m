//
// Created by Dmitry Sobolev on 18/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import "XBAccountManager.h"
#import "XBXMPPAccount.h"
#import "XBXMPPAccount.h"


@implementation XBAccountManager

+ (XBAccountManager *)sharedInstance {
    static XBAccountManager *sharedManager = nil;
    static dispatch_once_t once_token;

    dispatch_once(&once_token, ^{
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

- (void)addAccount:(NSDictionary *)data {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [XBXMPPAccount MR_importFromObject:data inContext:localContext];
    }];
}

- (void)deleteAccountWithID:(NSString *)accountID {
    XBXMPPAccount *account = [self findAccountByID:accountID];
    [account deletePassword];
    [account MR_deleteEntity];
}

- (NSArray *)accounts {
    return [XBXMPPAccount MR_findAll];
}

- (XBXMPPAccount *)findAccountByID:(NSString *)accountID {
    return [XBXMPPAccount MR_findFirstByAttribute:@"accountID" withValue:accountID];
}

@end