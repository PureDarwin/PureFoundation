/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSNumber.m
 *
 *	NSNumber, NSCFNumber, NSCFBoolean
 *
 *	Created by Stuart Crook on 15/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSValue.h"

/*
 *	Class bridged to CFNumber
 */
@interface NSCFNumber : NSNumber
@end

/*
 *	Class bridged to CFBoolean
 */
@interface NSCFBoolean : NSNumber
@end

/*
 *	Dummy NSCFNumber for use in +alloc-init chains
 */
Class _PFNSCFNumberClass = nil;


/*
 *	The NSNumber class cluster front-end
 */
@implementation NSNumber

+(void)initialize
{
	PF_HELLO("")
	
	if( self == [NSNumber class] )
		_PFNSCFNumberClass = objc_getClass("NSCFNumber");
}

+(id)alloc
{
	PF_HELLO("")
	
	if( self == [NSNumber class] )
		return (id)&_PFNSCFNumberClass;
	return [super alloc];
}

// NSNumberCreation class methods 
+ (NSNumber *)numberWithChar:(char)value
{
	PF_HELLO("")
	return [[[self alloc] initWithChar: value] autorelease];
}

+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value
{
	PF_HELLO("")
	return [[[self alloc] initWithUnsignedChar: value] autorelease];
}

+ (NSNumber *)numberWithShort:(short)value
{
	PF_HELLO("")
	return [[[self alloc] initWithShort: value] autorelease];
}

+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value
{
	PF_HELLO("")
	return [[[self alloc] initWithUnsignedShort: value] autorelease];
}

+ (NSNumber *)numberWithInt:(int)value
{
	PF_HELLO("")
	return [[[self alloc] initWithInt: value] autorelease];
}

+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value
{
	PF_HELLO("")
	return [[[self alloc] initWithUnsignedInt: value] autorelease];
}

+ (NSNumber *)numberWithLong:(long)value
{
	PF_HELLO("")
	return [[[self alloc] initWithLong: value] autorelease];
}

+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value
{
	PF_HELLO("")
	return [[[self alloc] initWithUnsignedLong: value] autorelease];
}

+ (NSNumber *)numberWithLongLong:(long long)value
{
	PF_HELLO("")
	return [[[self alloc] initWithLongLong: value] autorelease];
}

+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value
{
	PF_HELLO("")
	return [[[self alloc] initWithUnsignedLongLong: value] autorelease];
}

+ (NSNumber *)numberWithFloat:(float)value
{
	PF_HELLO("")
	return [[[self alloc] initWithFloat: value] autorelease];
}

+ (NSNumber *)numberWithDouble:(double)value
{
	PF_HELLO("")
	return [[[self alloc] initWithDouble: value] autorelease];
}

+ (NSNumber *)numberWithBool:(BOOL)value
{
	PF_HELLO("")
	return [[self alloc] initWithBool: value]; // don't autorelease because this will be one of 
}												// the two NSCFBoolean constants

+ (NSNumber *)numberWithInteger:(NSInteger)value
{
	PF_HELLO("")
	return [[[self alloc] initWithInteger: value] autorelease];
}

+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value
{
	PF_HELLO("")
	return [[[self alloc] initWithUnsignedInteger: value] autorelease];
}

// NSNumber instance methods -- which will never be called...
- (char)charValue { return 0; }
- (unsigned char)unsignedCharValue { return 0; }
- (short)shortValue { return 0; }
- (unsigned short)unsignedShortValue { return 0; }
- (int)intValue { return 0; }
- (unsigned int)unsignedIntValue { return 0; }
- (long)longValue { return 0; }
- (unsigned long)unsignedLongValue { return 0; }
- (long long)longLongValue { return 0; }
- (unsigned long long)unsignedLongLongValue { return 0; }
- (float)floatValue { return 0; }
- (double)doubleValue { return 0; }
- (BOOL)boolValue { return 0; }
- (NSInteger)integerValue { return 0; }
- (NSUInteger)unsignedIntegerValue { return 0; }

- (NSString *)stringValue { return nil; }
- (NSComparisonResult)compare:(NSNumber *)otherNumber { return 0; }
- (BOOL)isEqualToNumber:(NSNumber *)number { return NO; }
- (NSString *)descriptionWithLocale:(id)locale { return nil; }

@end



@implementation NSNumber (NSDecimalNumberExtensions)

- (NSDecimal)decimalValue { }

@end


/*
 *
 */




/*
 *	NSCFNumber, the bridged number class
 */
@implementation NSCFNumber

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFNumberGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

// because numbers are kept unique by CF
- (id)copyWithZone: (NSZone *)zone
{
	return self;
}

-(NSString *)description
{
	PF_HELLO("")
	return (NSString *)CFCopyDescription((CFTypeRef)self);
}

// (NSValueCreation is caught by superclass and passed to NSConcreteValue)

/*
 *	NSNumberCreation
 *
 *	These are invoked on the dummy _PFNSCFNumber, which then returns the newly-created and bridged
 *	CFNumber
 */
- (id)initWithChar:(char)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberCharType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithUnsignedChar:(unsigned char)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberCharType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithShort:(short)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberShortType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithUnsignedShort:(unsigned short)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberShortType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithInt:(int)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithUnsignedInt:(unsigned int)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithLong:(long)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberLongType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithUnsignedLong:(unsigned long)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberLongType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithLongLong:(long long)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberLongLongType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithUnsignedLongLong:(unsigned long long)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberLongLongType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithFloat:(float)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberFloatType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithDouble:(double)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberFloatType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithBool:(BOOL)value
{
	PF_HELLO("")
	return value ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
	//CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberBo, &value );
	//PF_RETURN_NEW(new)
}

- (id)initWithInteger:(NSInteger)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberNSIntegerType, &value );
	PF_RETURN_NEW(new)
}

- (id)initWithUnsignedInteger:(NSUInteger)value
{
	PF_HELLO("")
	CFNumberRef new = CFNumberCreate( kCFAllocatorDefault, kCFNumberNSIntegerType, &value );
	PF_RETURN_NEW(new)
}	

// NSValue instance methods
- (void)getValue:(void *)value {}
- (const char *)objCType { return 0; }

// NSNumber instance methods
- (char)charValue 
{
	PF_HELLO("")
	char value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberCharType, &value );
	return value;
}

- (unsigned char)unsignedCharValue 
{
	PF_HELLO("")
	unsigned char value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberCharType, &value );
	return value;	
}

- (short)shortValue 
{
	PF_HELLO("")
	short value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberShortType, &value );
	return value;
}

- (unsigned short)unsignedShortValue 
{
	PF_HELLO("")
	unsigned short value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberShortType, &value );
	return value;
}

- (int)intValue 
{
	PF_HELLO("")
	int value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberIntType, &value );
	return value;	
}

- (unsigned int)unsignedIntValue 
{
	PF_HELLO("")
	unsigned int value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberIntType, &value );
	return value;		
}

- (long)longValue 
{
	PF_HELLO("")
	long value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberLongType, &value );
	return value;		
}

- (unsigned long)unsignedLongValue 
{
	PF_HELLO("")
	unsigned long value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberLongType, &value );
	return value;		
}

- (long long)longLongValue 
{
	PF_HELLO("")
	long long value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberLongLongType, &value );
	return value;		
}

- (unsigned long long)unsignedLongLongValue 
{
	PF_HELLO("")
	unsigned long long value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberLongLongType, &value );
	return value;		
}

- (float)floatValue 
{
	PF_HELLO("")
	float value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberFloatType, &value );
	return value;			
}

- (double)doubleValue 
{
	PF_HELLO("")
	double value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberDoubleType, &value );
	return value;			
}

- (BOOL)boolValue 
{
	PF_TODO
	if( self == (id)kCFBooleanTrue ) return YES;
	if( self == (id)kCFBooleanFalse ) return NO;
	int i;
	CFNumberGetValue((CFNumberRef)self, kCFNumberIntType, &i);
	return (i == 0) ? NO : YES;
}

- (NSInteger)integerValue 
{
	PF_HELLO("")
	NSInteger value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberNSIntegerType, &value );
	return value;			
}

- (NSUInteger)unsignedIntegerValue 
{
	PF_HELLO("")
	NSUInteger value;
	CFNumberGetValue( (CFNumberRef)self, kCFNumberNSIntegerType, &value );
	return value;		
}

- (NSString *)stringValue 
{ 
	PF_TODO
	// check if its a float type, then get the vlaue and run throug a formatter
	return nil;
#warning still to do!
}

- (NSComparisonResult)compare:(NSNumber *)otherNumber 
{
	PF_HELLO("")
	return CFNumberCompare((CFNumberRef)self, (CFNumberRef)otherNumber, NULL);
}

- (BOOL)isEqualToNumber:(NSNumber *)number 
{
	PF_TODO
	if( self == number ) return YES;
	if( number == nil ) return NO;
	return ([self compare: number] == NSOrderedSame);
}

- (NSString *)descriptionWithLocale:(id)locale 
{
	PF_TODO
	return nil;
}

@end


/*
 *	NSCFBoolean, the other bridged number class
 *
 *	This cannot be alloced and never recieves init methods. It is a wrapper for one
 *	of the two kCFBoolean constants.
 */
@implementation NSCFBoolean

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFBooleanGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

-(id)copyWithZone:(NSZone *)zone
{
	return self; // because these are constants
}

// (NSValueCreation is caught by superclass and passed to NSConcreteValue)

// (NSNumberCreation is taken care of by NSCFNumber)
//- (id)initWithChar:(char)value;
//- (id)initWithUnsignedChar:(unsigned char)value;
//- (id)initWithShort:(short)value;
//- (id)initWithUnsignedShort:(unsigned short)value;
//- (id)initWithInt:(int)value;
//- (id)initWithUnsignedInt:(unsigned int)value;
//- (id)initWithLong:(long)value;
//- (id)initWithUnsignedLong:(unsigned long)value;
//- (id)initWithLongLong:(long long)value;
//- (id)initWithUnsignedLongLong:(unsigned long long)value;
//- (id)initWithFloat:(float)value;
//- (id)initWithDouble:(double)value;
//- (id)initWithBool:(BOOL)value;
//- (id)initWithInteger:(NSInteger)value;
//- (id)initWithUnsignedInteger:(NSUInteger)value;

// NSValue instance methods
//- (void)getValue:(void *)value {}
//- (const char *)objCType {}

// NSNumber instance methods
- (char)charValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned char)unsignedCharValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (short)shortValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned short)unsignedShortValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (int)intValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned int)unsignedIntValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (long)longValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned long)unsignedLongValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (long long)longLongValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (unsigned long long)unsignedLongLongValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (float)floatValue { return (self == (id)kCFBooleanTrue) ? 1.0 : 0.0; }
- (double)doubleValue { return (self == (id)kCFBooleanTrue) ? 1.0 : 0.0; }

- (BOOL)boolValue 
{
	PF_HELLO("")
	return (self == (id)kCFBooleanTrue) ? YES : NO; 
}

- (NSInteger)integerValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (NSUInteger)unsignedIntegerValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }

//- (NSString *)stringValue {}

- (NSComparisonResult)compare:(NSNumber *)otherNumber 
{
	
}

//- (BOOL)isEqualToNumber:(NSNumber *)number {}
//- (NSString *)descriptionWithLocale:(id)locale {}

@end

