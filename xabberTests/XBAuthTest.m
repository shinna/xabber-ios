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
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";
    [account save];

    [manager addAccount:account];

    XCTAssertEqual([manager accounts].count, 1u);
}

- (void)testTryAddNilAccount {
    [manager addAccount:nil];

    XCTAssertEqual(manager.accounts.count, 0u);
}

- (void)testTryToAddNotSavedAccount {
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";

    [manager addAccount:account];

    XCTAssertEqual([manager accounts].count, 0u);
}

- (void)testAccountFind {
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";
    [account save];

    [manager addAccount:account];

    XBAccount *foundAccount = [manager findAccountByID:@"accountName"];

    XCTAssertEqualObjects(account, foundAccount);
}

- (void)testTryToFindNotExistingAccount {
    XCTAssertNil([manager findAccountByID:@"accountName"]);
}

- (void)testAccountDeleteByID {
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";
    [account save];

    [manager addAccount:account];
    [manager deleteAccountWithID:@"accountName"];

    XCTAssertEqual(manager.accounts.count, 0u);
}

- (void)testTryToDeleteAccountByNotExistingID {
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";
    [account save];

    [manager addAccount:account];
    [manager deleteAccountWithID:@"account"];

    XCTAssertEqual(manager.accounts.count, 1u);
}

- (void)testDeleteAccount {
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";
    [account save];

    [manager addAccount:account];
    [manager deleteAccount:account];

    XCTAssertEqual(manager.accounts.count, 0u);
}

- (void)testDeleteNotExistingAccount {
    XBAccount *account = [XBAccount accountWithConnector:nil];
    account.accountID = @"accountName";
    XBAccount *account2 = [XBAccount accountWithConnector:nil];
    account2.accountID = @"accountName";
    [account save];

    [manager addAccount:account];
    [manager deleteAccount:account2];

    XCTAssertEqual(manager.accounts.count, 1u);
}

@end
