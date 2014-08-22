//
// Created by Dmitry Sobolev on 18/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import "XBAccountManager.h"
#import "XBXMPPCoreDataAccount.h"
#import "XBXMPPCoreDataAccount.h"


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
        [XBXMPPCoreDataAccount MR_importFromObject:data inContext:localContext];
    }];
}

- (void)deleteAccountWithID:(NSString *)accountID {
    XBXMPPCoreDataAccount *account = [self findAccountByID:accountID];
    [account deletePassword];
    [account MR_deleteEntity];
}

- (NSArray *)accounts {
    return [XBXMPPCoreDataAccount MR_findAll];
}

- (XBXMPPCoreDataAccount *)findAccountByID:(NSString *)accountID {
    return [XBXMPPCoreDataAccount MR_findFirstByAttribute:@"accountID" withValue:accountID];
}

@end