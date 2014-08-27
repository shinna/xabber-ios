//
//  AccountConnectorTests.m
//  xabber
//
//  Created by Dmitry Sobolev on 27/08/14.
//  Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SSKeychain/SSKeychainQuery.h>
#import "OCMock.h"
#import "XBConnector.h"
#import "XBAccount.h"

@interface AccountConnectorTests : XCTestCase {
    id mockConnector;
    id mockDelegate;
}

@end

@implementation AccountConnectorTests

- (void)setUp
{
    [super setUp];

    mockConnector = OCMProtocolMock(@protocol(XBConnector));
    mockDelegate = OCMProtocolMock(@protocol(XBAccountDelegate));
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetAccountOfConnector {
    OCMExpect([mockConnector setAccount:[OCMArg any]]);
    [XBAccount accountWithConnector:mockConnector];

    OCMVerifyAll(mockConnector);
}

- (void)testWillLoginDelegate {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;

    OCMExpect([mockDelegate accountWillLogin:account]);

    [account login];

    OCMVerifyAll(mockDelegate);
}

- (void)testAccountDidLoginSuccessfully {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;

    OCMExpect([mockDelegate accountDidLoginSuccessfully:account]);
    OCMStub([mockConnector loginWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        void (^completionHandler)(NSError *error) = nil;

        [invocation getArgument:&completionHandler atIndex:2];
        completionHandler(nil);
    });

    [account login];

    OCMVerifyAll(mockDelegate);
}

- (void)testAccountCannotLoginWithError {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;
    NSError *e = [NSError errorWithDomain:@"test" code:1 userInfo:nil];

    OCMExpect([mockDelegate account:account didNotLoginWithError:e]);
    OCMStub([mockConnector loginWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        void (^completionHandler)(NSError *error) = nil;

        [invocation getArgument:&completionHandler atIndex:2];
        completionHandler(e);
    });

    [account login];

    OCMVerifyAll(mockDelegate);
}

- (void)testWillLogoutDelegate {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;

    OCMExpect([mockDelegate accountWillLogout:account];);

    [account logout];

    OCMVerifyAll(mockDelegate);
}

- (void)testTryLogoutWhenAccountLoggedOutAlready {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;
    NSError *e = [NSError errorWithDomain:@"xabberErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Account already logged out"}];

    OCMStub([mockConnector isLoggedIn]).andReturn(NO);
    OCMExpect([mockDelegate account:account didNotLogoutWithError:e]);

    [account logout];

    OCMVerifyAll(mockDelegate);
}

- (void)testAccountDidLogoutSuccessfully {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;

    OCMExpect([mockDelegate accountDidLogoutSuccessfully:account]);
    OCMStub([mockConnector logoutWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        void (^completionHandler)(NSError *error) = nil;

        [invocation getArgument:&completionHandler atIndex:2];
        completionHandler(nil);
    });

    [account logout];

    OCMVerifyAll(mockDelegate);
}

- (void)testAccountCannotLogoutWithError {
    XBAccount *account = [XBAccount accountWithConnector:mockConnector];
    account.delegate = mockDelegate;
    NSError *e = [NSError errorWithDomain:@"test" code:1 userInfo:nil];

    OCMExpect([mockDelegate account:account didNotLogoutWithError:e]);
    OCMStub([mockConnector logoutWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        void (^completionHandler)(NSError *error) = nil;

        [invocation getArgument:&completionHandler atIndex:2];
        completionHandler(e);
    });

    [account logout];

    OCMVerifyAll(mockDelegate);
}

@end
