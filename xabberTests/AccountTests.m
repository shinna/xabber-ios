//
//  AccountTests.m
//  xabber
//
//  Created by Dmitry Sobolev on 22/08/14.
//  Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
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
    XBAccount *acc = [XBAccount accountWithAccountID:@"account"];

    [acc save];

    XCTAssertEqual([XBXMPPCoreDataAccount MR_findAll].count, 1u);
}

- (void)testNotCreatingDuplicates {
    XBAccount *acc = [XBAccount accountWithAccountID:@"account"];

    [acc save];
    [acc save];

    XCTAssertEqual([XBXMPPCoreDataAccount MR_findAll].count, 1u);
}

- (void)testDefaults {
    XBAccount *acc = [XBAccount accountWithAccountID:@"account"];

    XCTAssertEqual(acc.autoLogin, YES);
    XCTAssertEqual(acc.port, 5222);
    XCTAssertEqual(acc.status, XBAccountStatusAvailable);
}

- (void)testRestoreFromCoreData {
    XBAccount *acc1 = [XBAccount accountWithAccountID:@"account"];
    acc1.password = @"123";
    acc1.host = @"example.com";

    [acc1 save];

    XBAccount *acc2 = [XBAccount accountWithCoreDataAccount:[XBXMPPCoreDataAccount MR_findFirstByAttribute:@"accountID" withValue:@"account"]];

    XCTAssertEqualObjects(acc1, acc2);
}

@end
