//
// Created by Dmitry Sobolev on 31/08/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import "XMPPPresence+XBEquality.h"


@implementation XMPPPresence (XBEquality)
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToPresence:other];
}

- (BOOL)isEqualToPresence:(XMPPPresence *)other {
    if (self == other)
        return YES;
    if (other == nil)
        return NO;
    if (self.type && ![self.type isEqualToString:other.type])
        return NO;
    if (self.show && ![self.show isEqualToString:other.show])
        return NO;
    if (self.status && ![self.status isEqualToString:other.status])
        return NO;
    if (self.priority != other.priority)
        return NO;
    if (self.intShow != other.intShow)
        return NO;
    if (self.isErrorPresence != other.isErrorPresence)
        return NO;

    return YES;
}

@end