//
//  XMPPConnectorTests.m
//  xabber
//
//  Created by Dmitry Sobolev on 28/08/14.
//  Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XBXMPPConnector.h"
#import "XMPPStream.h"
#import "OCMock.h"
#import "XMPPModule.h"
#import "XBError.h"

@interface XMPPConnectorTests : XCTestCase {
    id mockXMPPStream;
    id mockConnector;
}
@end

@implementation XMPPConnectorTests

- (void)setUp
{
    [super setUp];

    XBXMPPConnector *connector = [[XBXMPPConnector alloc] init];
    mockConnector = OCMPartialMock(connector);
    mockXMPPStream = OCMClassMock([XMPPStream class]);
    OCMStub([mockConnector xmppStream]).andReturn(mockXMPPStream);
}

- (void)tearDown
{
    [mockConnector stopMocking];
    [mockXMPPStream stopMocking];

    [super tearDown];
}

- (void)testXMPPStreamIsConnected {
    OCMStub([mockXMPPStream isDisconnected]).andReturn(NO);

    [mockConnector loginWithCompletion:^(NSError *e){
        NSError *testError = [NSError errorWithDomain:XBXabberErrorDomain
                                                 code:XBLoginValidationError
                                             userInfo:@{NSLocalizedDescriptionKey: @"Stream already connected"}];
        XCTAssertEqualObjects(e, testError);
    }];
}

- (void)testAccountNotValid {
    XBAccount *acc = [XBAccount accountWithConnector:nil];

    OCMStub([mockXMPPStream isDisconnected]).andReturn(YES);
    OCMStub([mockConnector account]).andReturn(acc);

    [mockConnector loginWithCompletion:^(NSError *e){
        NSError *testError = [NSError errorWithDomain:XBXabberErrorDomain
                                                 code:XBLoginValidationError
                                             userInfo:@{NSLocalizedDescriptionKey: @"Login or password are empty"}];
        XCTAssertEqualObjects(e, testError);
    }];
}

- (void)testCouldNotConnect {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"test";
    acc.password = @"password";
    NSError *testError = [NSError errorWithDomain:@""
                                             code:-1
                                         userInfo:nil];

    OCMStub([mockXMPPStream isDisconnected]).andReturn(YES);
    OCMStub([mockConnector account]).andReturn(acc);
    OCMStub([mockXMPPStream connectWithTimeout:XMPPStreamTimeoutNone
                                         error:(NSError __autoreleasing **)[OCMArg setTo:testError]]).andReturn(NO);

    [mockConnector loginWithCompletion:^(NSError *e){
        XCTAssertEqualObjects(e, testError);
    }];
}

- (void)testStreamNotAuthenticate {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"test";
    acc.password = @"password";
    NSError *testError = [NSError errorWithDomain:@""
                                             code:-1
                                         userInfo:nil];

    OCMStub([mockXMPPStream isDisconnected]).andReturn(YES);
    OCMStub([mockConnector account]).andReturn(acc);
    OCMStub([mockXMPPStream connectWithTimeout:XMPPStreamTimeoutNone
                                         error:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMStub([mockXMPPStream authenticateWithPassword:acc.password
                                               error:(NSError __autoreleasing **)[OCMArg setTo:testError]]).andReturn(NO);

    [mockConnector loginWithCompletion:^(NSError *e){
        XCTAssertEqualObjects(e, testError);
    }];

    [mockConnector xmppStreamDidConnect:mockXMPPStream];
}

- (void)testXMPPStreamDidAuthenticated {
    XBAccount *acc = [XBAccount accountWithConnector:nil];
    acc.accountID = @"test";
    acc.password = @"password";
    acc.status = XBAccountStatusAvailable;

    OCMStub([mockXMPPStream isDisconnected]).andReturn(YES);
    OCMStub([mockConnector account]).andReturn(acc);
    OCMStub([mockXMPPStream connectWithTimeout:XMPPStreamTimeoutNone
                                         error:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMStub([mockConnector setNewStatus:XBAccountStatusAvailable]);

    [mockConnector loginWithCompletion:^(NSError *e){
        XCTAssertNil(e);
    }];

    XCTAssertFalse([mockConnector isLoggedIn]);

    [mockConnector xmppStreamDidAuthenticate:mockXMPPStream];

    XCTAssertTrue([mockConnector isLoggedIn]);
}

@end
