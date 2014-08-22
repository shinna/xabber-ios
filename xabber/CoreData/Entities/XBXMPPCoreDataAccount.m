#import "XBXMPPCoreDataAccount.h"
#import "SSKeychain.h"

static NSString *const XBKeychainServiceName = @"xabberService";

@interface XBXMPPCoreDataAccount () {
    NSString *_password;
}
@end


@implementation XBXMPPCoreDataAccount

- (NSString *)password {
    if (!_password) {
        _password = [SSKeychain passwordForService:XBKeychainServiceName account:self.accountID];
    }

    return _password;
}

- (BOOL)setPassword:(NSString *)password {
    if (!self.accountID || !password) {
        return NO;
    }

    _password = password;

    return [SSKeychain setPassword:password forService:XBKeychainServiceName account:self.accountID];
}

- (BOOL)deletePassword {
    BOOL isDeleted = [SSKeychain deletePasswordForService:XBKeychainServiceName account:self.accountID];

    if (isDeleted) {
        _password = nil;
    }

    return isDeleted;
}

#pragma mark Import

- (BOOL)didImport:(NSDictionary *)data {
    NSString *password = data[@"password"];
    [self setPassword:password];
    return YES;
}

@end
