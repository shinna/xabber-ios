// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XBXMPPAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct XBXMPPAccountAttributes {
	__unsafe_unretained NSString *accountID;
	__unsafe_unretained NSString *autoLogin;
	__unsafe_unretained NSString *host;
	__unsafe_unretained NSString *port;
	__unsafe_unretained NSString *status;
} XBXMPPAccountAttributes;

extern const struct XBXMPPAccountRelationships {
} XBXMPPAccountRelationships;

extern const struct XBXMPPAccountFetchedProperties {
} XBXMPPAccountFetchedProperties;








@interface XBXMPPAccountID : NSManagedObjectID {}
@end

@interface _XBXMPPAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (XBXMPPAccountID*)objectID;





@property (nonatomic, strong) NSString* accountID;



//- (BOOL)validateAccountID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* autoLogin;



@property BOOL autoLoginValue;
- (BOOL)autoLoginValue;
- (void)setAutoLoginValue:(BOOL)value_;

//- (BOOL)validateAutoLogin:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* host;



//- (BOOL)validateHost:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* port;



@property int16_t portValue;
- (int16_t)portValue;
- (void)setPortValue:(int16_t)value_;

//- (BOOL)validatePort:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* status;



@property int16_t statusValue;
- (int16_t)statusValue;
- (void)setStatusValue:(int16_t)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;






@end

@interface _XBXMPPAccount (CoreDataGeneratedAccessors)

@end

@interface _XBXMPPAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAccountID;
- (void)setPrimitiveAccountID:(NSString*)value;




- (NSNumber*)primitiveAutoLogin;
- (void)setPrimitiveAutoLogin:(NSNumber*)value;

- (BOOL)primitiveAutoLoginValue;
- (void)setPrimitiveAutoLoginValue:(BOOL)value_;




- (NSString*)primitiveHost;
- (void)setPrimitiveHost:(NSString*)value;




- (NSNumber*)primitivePort;
- (void)setPrimitivePort:(NSNumber*)value;

- (int16_t)primitivePortValue;
- (void)setPrimitivePortValue:(int16_t)value_;




- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (int16_t)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(int16_t)value_;




@end
