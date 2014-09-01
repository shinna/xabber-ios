//
// Created by Dmitry Sobolev on 01/09/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import "XBAccountFactory.h"
#import "XBAccount.h"
#import "XBConnector.h"
#import "XBXMPPConnector.h"


@implementation XBAccountFactory {

}
+ (XBAccount *)createAccountWithType:(XBAccountType)type {
    id <XBConnector> connector;

    switch (type) {
        case XBXMPPAccount:
            connector = [[XBXMPPConnector alloc] init];
            break;
        default:
            return nil;
    }

    return [XBAccount accountWithConnector:connector];
}

@end