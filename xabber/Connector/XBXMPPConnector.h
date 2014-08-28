//
// Created by Dmitry Sobolev on 26/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBConnector.h"

@class XBAccount;
@class XMPPStream;

@interface XBXMPPConnector : NSObject <XBConnector>
@property(nonatomic, readonly) XMPPStream *xmppStream;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToConnector:(XBXMPPConnector *)connector;

- (NSUInteger)hash;

@end
