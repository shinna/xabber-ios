#import "_XBXMPPAccount.h"

@interface XBXMPPAccount : _XBXMPPAccount {}


- (NSString *)password;

- (BOOL)setPassword:(NSString *)password;

- (BOOL)deletePassword;
@end
