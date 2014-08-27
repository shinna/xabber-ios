//
//  AccountTests.m
//  xabber
//
//  Created by Dmitry Sobolev on 22/08/14.
//  Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SSKeychain/SSKeychain.h>
#import "XBAccount.h"
#import "XBXMPPCoreDataAccount.h"

@interface AccountTests : XCTestCase

@end

@implementation AccountTests

- (void)setUp
{
    [super setUp];

    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown
{
    [MagicalRecord cleanUp];

    [super tearDown];
}

- (void)testAccountSave {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    [acc save];

    XCTAssertEqual([XBXMPPCoreDataAccount MR_findAll].count, 1u);
}

- (void)testAccountIsNew {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    XCTAssertTrue(acc.isNew);
}

- (void)testCreatedEmptyAccountIsNew {
    XBAccount *acc = [XBAccount accountWithConnector:nil];

    XCTAssertTrue(acc.isNew);
}

- (void)testAccountNotNewAfterSave {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    [acc save];

    XCTAssertFalse(acc.isNew);
}

- (void)testLoadedFromCoreDataAccountNotNew {
    XBAccount *acc1 = [XBAccount accountWithConnector:nil];
    acc1.accountID = @"account";
    [acc1 save];

    XBAccount *acc2 = [XBAccount accountWithConnector:nil coreDataAccount:[XBXMPPCoreDataAccount MR_findFirstByAttribute:@"accountID" withValue:@"account"]];

    XCTAssertFalse(acc2.isNew);
}

- (void)testNotCreatingDuplicates {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    [acc save];
    [acc save];

    XCTAssertEqual([XBXMPPCoreDataAccount MR_findAll].count, 1u);
}

- (void)testDefaults {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    XCTAssertTrue(acc.autoLogin);
    XCTAssertEqual(acc.port, 5222);
    XCTAssertEqual(acc.status, XBAccountStatusAvailable);
    XCTAssertTrue(acc.isNew);
    XCTAssertFalse(acc.isDeleted);
}

- (void)testRestoreFromCoreData {
    XBAccount *acc1 = [XBAccount accountWithConnector:nil];
    acc1.accountID = @"account";
    acc1.password = @"123";
    acc1.host = @"example.com";

    [acc1 save];

    XBAccount *acc2 = [XBAccount accountWithConnector:nil coreDataAccount:[XBXMPPCoreDataAccount MR_findFirstByAttribute:@"accountID" withValue:@"account"]];

    XCTAssertEqualObjects(acc1, acc2);
}

- (void)testCannotSaveIfAccountIDAlreadyUsed {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    [acc save];

    XBAccount *acc2 = [XBAccount accountWithConnector:nil];
    acc2.accountID = @"account";

    XCTAssertFalse([acc2 save]);
}

- (void)testDeleteAccount {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    [acc save];

    [acc delete];

    XCTAssertTrue(acc.isDeleted);
    XCTAssertEqual([XBXMPPCoreDataAccount MR_findAll].count, 0);
    XCTAssertNil([SSKeychain passwordForService:@"xabberService" account:@"account"]);
}

- (void)testDeleteNotSavedAccount {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"account";

    XCTAssertFalse([acc delete]);
    XCTAssertFalse(acc.isDeleted);
}

- (void)testCompareAccountsWithEqualData {
    XBAccount *acc1 = [XBAccount accountWithConnector:nil];
    acc1.accountID = @"account";
    XBAccount *acc2 = [XBAccount accountWithConnector:nil];
    acc2.accountID = @"account";

    [acc1 save];

    XCTAssertNotEqualObjects(acc1, acc2);
}

@end
