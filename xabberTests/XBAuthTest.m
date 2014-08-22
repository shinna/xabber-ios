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

    manager = [XBAccountManager sharedInstance];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown
{
    [MagicalRecord cleanUp];

    for (NSDictionary *account in [SSKeychain accountsForService:@"xabberService"]) {
        [SSKeychain deletePasswordForService:@"xabberService" account:account[(__bridge id)kSecAttrAccount]];
    }

    [super tearDown];
}

- (void)testAccountAdd {

    [manager addAccount:@{@"accountID": @"accountName"}];

    XCTAssertEqual([manager accounts].count, 1);
}

- (void)testTryAddAccountWithInvalidData {
    [manager addAccount:@{}];

    XCTAssertEqual(manager.accounts.count, 0);
}

- (void)testAccountIDValidatorReturnError {
    id errorHandlerObject = OCMProtocolMock(@protocol(ErrorHandlerProtocol));
    OCMExpect([errorHandlerObject errorHandler:[OCMArg checkWithBlock:^BOOL(NSError *error) {
        return [error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSValidationMissingMandatoryPropertyError;
    }]]);

    [MagicalRecord setErrorHandlerTarget:errorHandlerObject action:@selector(errorHandler:)];

    [manager addAccount:@{}];

    OCMVerifyAll(errorHandlerObject);
}

- (void)testAccountFind {
    [manager addAccount:@{@"accountID": @"accountName"}];

    XBXMPPCoreDataAccount *account = [manager findAccountByID:@"accountName"];

    XCTAssertNotNil(account);
    XCTAssertEqualObjects(account.accountID, @"accountName");
}

- (void)testAccountRemove {
    [manager addAccount:@{@"accountID": @"accountName"}];
    [manager deleteAccountWithID:@"accountName"];

    XCTAssertEqual([XBAccountManager sharedInstance].accounts.count, 0);
}

- (void)testSetPassword {
    [manager addAccount:@{@"accountID": @"accountName"}];

    XBXMPPCoreDataAccount *account = [manager findAccountByID:@"accountName"];

    BOOL accountSetResult = [account setPassword:@"password"];

    XCTAssertTrue(accountSetResult);
    XCTAssertEqualObjects(account.password, @"password");
}

- (void)testSetPasswordWithEmptyAccountID {
    XBXMPPCoreDataAccount *account = [XBXMPPCoreDataAccount MR_createEntity];

    BOOL accountSetResult = [account setPassword:@"password"];

    XCTAssertFalse(accountSetResult);
    XCTAssertNil(account.password);
}

- (void)testSetNilPassword {
    [manager addAccount:@{@"accountID": @"accountName"}];

    XBXMPPCoreDataAccount *account = [manager findAccountByID:@"accountName"];

    BOOL accountSetResult = [account setPassword:nil];

    XCTAssertFalse(accountSetResult);
    XCTAssertNil(account.password);
}

- (void)testAddAccountWithPassword {
    [manager addAccount:@{@"accountID": @"accountName", @"password": @"password"}];

    XBXMPPCoreDataAccount *account = [manager findAccountByID:@"accountName"];

    XCTAssertEqualObjects(account.password, @"password");
}

- (void)testDeletePassword {
    [manager addAccount:@{@"accountID": @"accountName", @"password": @"password"}];

    XBXMPPCoreDataAccount *account = [manager findAccountByID:@"accountName"];

    [account deletePassword];

    XCTAssertNil(account.password);
}

- (void)testDeletePasswordOnAccountDelete {
    [manager addAccount:@{@"accountID": @"accountName", @"password": @"password"}];

    [manager deleteAccountWithID:@"accountName"];

    XCTAssertNil([SSKeychain passwordForService:@"xabberService" account:@"accountName"]);
}

@end
