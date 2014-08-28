//
// Created by Dmitry Sobolev on 26/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import "XBXMPPConnector.h"
#import "XMPPFramework.h"
#import "XBError.h"
#import "XMPPStream.h"

@interface XBXMPPConnector () <XMPPStreamDelegate> {
    XMPPReconnect *_xmppReconnect;
    XMPPRosterCoreDataStorage *_xmppRosterStorage;
    XMPPRoster *_xmppRoster;
    XMPPvCardCoreDataStorage *_xmppVCardStorage;
    XMPPvCardTempModule *_xmppVCardTempModule;
    XMPPvCardAvatarModule *_xmppVCardAvatarModule;

    BOOL _allowSelfSignedCertificates;
    BOOL _allowSSLHostNameMismatch;
    BOOL _isLoggedIn;

    void (^_completionHandler)(NSError *error);
}

- (void)setupStream;

- (void)teardownStream;

- (void)goOnline;

- (void)goOffline;

- (void)completeWithError:(NSError *)error;

@end


@implementation XBXMPPConnector {
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupStream];
        _isLoggedIn = NO;
    }

    return self;
}

- (void)dealloc {
    [self teardownStream];
}

#pragma mark Login/logout

- (BOOL)isLoggedIn {
    return _isLoggedIn;
}

- (void)loginWithCompletion:(void (^)(NSError *error))completionHandler {
    _completionHandler = completionHandler;

    if (![self.xmppStream isDisconnected]) {
        DDLogError(@"Stream already connected");
        [self completeWithError:[NSError errorWithDomain:XBXabberErrorDomain
                                                    code:XBLoginValidationError
                                                userInfo:@{NSLocalizedDescriptionKey: @"Stream already connected"}]];
        return;
    }

    if (self.account.accountID == nil || self.account.password == nil) {
        DDLogError(@"Login or password are empty");
        [self completeWithError:[NSError errorWithDomain:XBXabberErrorDomain
                                                    code:XBLoginValidationError
                                                userInfo:@{NSLocalizedDescriptionKey: @"Login or password are empty"}]];
        return;
    }

    self.xmppStream.hostName = self.account.host;
    self.xmppStream.hostPort = (UInt16) self.account.port;
    self.xmppStream.myJID = [XMPPJID jidWithString:self.account.accountID];

    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        DDLogError(@"Error connecting: %@", error);
        [self completeWithError:error];
        return;
    }
    return;
}

- (void)logoutWithCompletion:(void (^)(NSError *error))completionHandler {
    [self goOffline];
    [self.xmppStream disconnectAfterSending];
}

- (void)setNewStatus:(XBAccountStatus)status {
    XMPPPresence *presence = [XMPPPresence presence];
    NSString *domain = [self.xmppStream.myJID domain];

    if([domain isEqualToString:@"gmail.com"]
            || [domain isEqualToString:@"gtalk.com"]
            || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }

    [self.xmppStream sendElement:presence];
}

#pragma mark Setup/teardown stream

- (void)setupStream {
    NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");

    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    _xmppStream = [[XMPPStream alloc] init];
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        // When you try to set the associated property on the simulator, it simply fails.
        // And when you background an app on the simulator,
        // it just queues network traffic til the app is foregrounded again.
        // We are patiently waiting for a fix from Apple.
        // If you do enableBackgroundingOnSocket on the simulator,
        // you will simply see an error message from the xmpp stack when it fails to set the property.
        _xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif

    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    _xmppReconnect = [[XMPPReconnect alloc] init];

    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
    _xmppRoster.autoFetchRoster = YES;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    _xmppVCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppVCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppVCardStorage];
    _xmppVCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppVCardTempModule];

    // Activate xmpp modules
    [_xmppReconnect activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppVCardTempModule activate:_xmppStream];
    [_xmppVCardAvatarModule activate:_xmppStream];

    // Add ourself as a delegate to anything we may be interested in
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

    _allowSelfSignedCertificates = NO;
    _allowSSLHostNameMismatch = NO;
}

- (void)teardownStream {
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    [_xmppReconnect deactivate];
    [_xmppRoster deactivate];
    [_xmppVCardTempModule deactivate];
    [_xmppVCardAvatarModule deactivate];
    [_xmppStream disconnect];

    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    _xmppVCardStorage = nil;
    _xmppVCardTempModule = nil;
    _xmppVCardAvatarModule = nil;
}

#pragma mark Private

- (void)completeWithError:(NSError *)error {
    _completionHandler(error);
    _completionHandler = nil;
}

- (void)goOnline {
    [self setNewStatus:self.account.status];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

#pragma mark XMPPStream delegate

- (void)xmppStreamWillConnect:(XMPPStream *)sender {

}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (_allowSelfSignedCertificates)
    {
        settings[(NSString *) kCFStreamSSLAllowsAnyRoot] = @YES;
    }
    if (_allowSSLHostNameMismatch)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = [NSNull null];
    }
    else
    {

        // Google does things incorrectly (does not conform to RFC).
        // Because so many people ask questions about this (assume xmpp framework is broken),
        // I've explicitly added code that shows how other xmpp clients "do the right thing"
        // when connecting to a google server (gmail, or google apps for domains).
        NSString *expectedCertName = nil;
        NSString *serverDomain = self.xmppStream.hostName;
        NSString *virtualDomain = [self.xmppStream.myJID domain];
        if ([serverDomain isEqualToString:@"talk.google.com"])
        {
            if ([virtualDomain isEqualToString:@"gmail.com"])
            {
                expectedCertName = virtualDomain;
            }
            else
            {
                expectedCertName = serverDomain;
            }
        }
        else if (serverDomain == nil)
        {
            expectedCertName = virtualDomain;
        }
        else
        {
            expectedCertName = serverDomain;
        }
        if (expectedCertName)
        {
            settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
        }
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender {

}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSError *error = nil;
    if (![self.xmppStream authenticateWithPassword:self.account.password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
        [self completeWithError:error];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];

    _isLoggedIn = YES;
    [self completeWithError:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    [self completeWithError:[NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Stream didn't authenticate"}]];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    [self completeWithError:error];
}

#pragma mark Equality

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToConnector:other];
}

- (BOOL)isEqualToConnector:(XBXMPPConnector *)connector {
    if (self == connector)
        return YES;
    if (connector == nil)
        return NO;
    if (_xmppReconnect != connector->_xmppReconnect && ![_xmppReconnect isEqual:connector->_xmppReconnect])
        return NO;
    if (self.xmppStream != connector.xmppStream && ![self.xmppStream isEqual:connector.xmppStream])
        return NO;
    if (_xmppRosterStorage != connector->_xmppRosterStorage && ![_xmppRosterStorage isEqual:connector->_xmppRosterStorage])
        return NO;
    if (_xmppRoster != connector->_xmppRoster && ![_xmppRoster isEqual:connector->_xmppRoster])
        return NO;
    if (_xmppVCardStorage != connector->_xmppVCardStorage && ![_xmppVCardStorage isEqual:connector->_xmppVCardStorage])
        return NO;
    if (_xmppVCardTempModule != connector->_xmppVCardTempModule && ![_xmppVCardTempModule isEqual:connector->_xmppVCardTempModule])
        return NO;
    if (_xmppVCardAvatarModule != connector->_xmppVCardAvatarModule && ![_xmppVCardAvatarModule isEqual:connector->_xmppVCardAvatarModule])
        return NO;
    if (_allowSelfSignedCertificates != connector->_allowSelfSignedCertificates)
        return NO;
    if (_allowSSLHostNameMismatch != connector->_allowSSLHostNameMismatch)
        return NO;
    if (_isLoggedIn != connector->_isLoggedIn)
        return NO;
    if (_completionHandler != connector->_completionHandler)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [_xmppReconnect hash];
    hash = hash * 31u + [self.xmppStream hash];
    hash = hash * 31u + [_xmppRosterStorage hash];
    hash = hash * 31u + [_xmppRoster hash];
    hash = hash * 31u + [_xmppVCardStorage hash];
    hash = hash * 31u + [_xmppVCardTempModule hash];
    hash = hash * 31u + [_xmppVCardAvatarModule hash];
    hash = hash * 31u + _allowSelfSignedCertificates;
    hash = hash * 31u + _allowSSLHostNameMismatch;
    hash = hash * 31u + _isLoggedIn;
    hash = hash * 31u + (NSUInteger) _completionHandler;
    return hash;
}


@end