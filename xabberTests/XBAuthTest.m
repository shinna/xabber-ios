//
//  XBAuthTest.m
//  xabber
//
//  Created by Dmitry Sobolev on 15/08/14.
//  Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XBXMPPCoreDataAccount.h"
#import "XBAccountManager.h"
#import "OCMock/OCMock.h"
#import "SSKeychain.h"
#import "XBAccount.h"

@interface XBAuthTest : XCTestCase {
    XBAccountManager *manager;
}

@end

@protocol ErrorHandlerProtocol

- (void)errorHandler:(NSError *)error;

@end

@implementation XBAuthTest

- (void)setUp
{
    [super setUp];

    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    manager = [XBAccountManager sharedInstance];
}

- (void)tearDown
{
    for (XBAccount *account in manager.accounts) {
        [manager deleteAccountWithID:account.accountID];
    }

    [MagicalRecord cleanUp];

    [super tearDown];
}

- (void)testAccountAdd {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];
    [account save];

    [manager addAccount:account];

    XCTAssertEqual([manager accounts].count, 1);
}

- (void)testTryAddNilAccount {
    [manager addAccount:nil];

    XCTAssertEqual(manager.accounts.count, 0);
}

- (void)testTryToAddNotSavedAccount {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];

    [manager addAccount:account];

    XCTAssertEqual([manager accounts].count, 0);
}

- (void)testAccountFind {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];
    [account save];

    [manager addAccount:account];

    XBAccount *foundAccount = [manager findAccountByID:@"accountName"];

    XCTAssertEqualObjects(account, foundAccount);
}

- (void)testTryToFindNotExistingAccount {
    XCTAssertNil([manager findAccountByID:@"accountName"]);
}

- (void)testAccountDeleteByID {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];
    [account save];

    [manager addAccount:account];
    [manager deleteAccountWithID:@"accountName"];

    XCTAssertEqual(manager.accounts.count, 0);
}

- (void)testTryToDeleteAccountByNotExistingID {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];
    [account save];

    [manager addAccount:account];
    [manager deleteAccountWithID:@"account"];

    XCTAssertEqual(manager.accounts.count, 1);
}

- (void)testDeleteAccount {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];
    [account save];

    [manager addAccount:account];
    [manager deleteAccount:account];

    XCTAssertEqual(manager.accounts.count, 0);
}

- (void)testDeleteNotExistingAccount {
    XBAccount *account = [XBAccount accountWithAccountID:@"accountName"];
    XBAccount *account2 = [XBAccount accountWithAccountID:@"accountName"];
    [account save];

    [manager addAccount:account];
    [manager deleteAccount:account2];

    XCTAssertEqual(manager.accounts.count, 1);
}

@end
