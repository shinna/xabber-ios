//
// Created by Dmitry Sobolev on 01/09/14.
// Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    XBXMPPAccount
} XBAccountType;

@class XBAccount;


@interface XBAccountFactory : NSObject

+ (XBAccount *)createAccountWithType:(XBAccountType)type;

@end