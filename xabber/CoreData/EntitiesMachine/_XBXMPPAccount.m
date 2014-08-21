// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XBXMPPAccount.m instead.

#import "_XBXMPPAccount.h"

const struct XBXMPPAccountAttributes XBXMPPAccountAttributes = {
	.accountID = @"accountID",
	.autoLogin = @"autoLogin",
	.host = @"host",
	.port = @"port",
	.status = @"status",
};

const struct XBXMPPAccountRelationships XBXMPPAccountRelationships = {
};

const struct XBXMPPAccountFetchedProperties XBXMPPAccountFetchedProperties = {
};

@implementation XBXMPPAccountID
@end

@implementation _XBXMPPAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"XBXMPPAccount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"XBXMPPAccount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"XBXMPPAccount" inManagedObjectContext:moc_];
}

- (XBXMPPAccountID*)objectID {
	return (XBXMPPAccountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"autoLoginValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"autoLogin"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"portValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"port"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"statusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic accountID;






@dynamic autoLogin;



- (BOOL)autoLoginValue {
	NSNumber *result = [self autoLogin];
	return [result boolValue];
}

- (void)setAutoLoginValue:(BOOL)value_ {
	[self setAutoLogin:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAutoLoginValue {
	NSNumber *result = [self primitiveAutoLogin];
	return [result boolValue];
}

- (void)setPrimitiveAutoLoginValue:(BOOL)value_ {
	[self setPrimitiveAutoLogin:[NSNumber numberWithBool:value_]];
}





@dynamic host;






@dynamic port;



- (int16_t)portValue {
	NSNumber *result = [self port];
	return [result shortValue];
}

- (void)setPortValue:(int16_t)value_ {
	[self setPort:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePortValue {
	NSNumber *result = [self primitivePort];
	return [result shortValue];
}

- (void)setPrimitivePortValue:(int16_t)value_ {
	[self setPrimitivePort:[NSNumber numberWithShort:value_]];
}





@dynamic status;



- (int16_t)statusValue {
	NSNumber *result = [self status];
	return [result shortValue];
}

- (void)setStatusValue:(int16_t)value_ {
	[self setStatus:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result shortValue];
}

- (void)setPrimitiveStatusValue:(int16_t)value_ {
	[self setPrimitiveStatus:[NSNumber numberWithShort:value_]];
}










@end
