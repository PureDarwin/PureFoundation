/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSNumber.m
 *
 *	NSNumber, __NSCFNumber, __NSCFBoolean
 *
 *	Created by Stuart Crook on 15/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSValue.h"
#import <objc/runtime.h> // for variable types

#define SELF    ((CFNumberRef)self)

@interface __NSCFNumber : NSNumber
@end

@interface __NSCFBoolean : NSNumber
@end

// TODO: Check whether the CFNumberType used in each of the creation methods makes sense given the type

@implementation NSNumber

#pragma mark - factory methods

+ (NSNumber *)numberWithChar:(char)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &value) autorelease];
}

+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &value) autorelease];
}

+ (NSNumber *)numberWithShort:(short)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &value) autorelease];
}

+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &value) autorelease];
}

+ (NSNumber *)numberWithInt:(int)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value) autorelease];
}

+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value) autorelease];
}

+ (NSNumber *)numberWithLong:(long)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &value) autorelease];
}

+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &value) autorelease];
}

+ (NSNumber *)numberWithLongLong:(long long)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &value) autorelease];
}

+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &value) autorelease];
}

+ (NSNumber *)numberWithFloat:(float)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value) autorelease];
}

+ (NSNumber *)numberWithDouble:(double)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &value) autorelease];
}

+ (NSNumber *)numberWithBool:(BOOL)value {
    return value ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

+ (NSNumber *)numberWithInteger:(NSInteger)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &value) autorelease];
}

+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value {
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &value) autorelease];
}

#pragma mark - init methods

- (id)initWithChar:(char)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &value);
}

- (id)initWithUnsignedChar:(unsigned char)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &value);
}

- (id)initWithShort:(short)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &value);
}

- (id)initWithUnsignedShort:(unsigned short)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &value);
}

- (id)initWithInt:(int)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value);
}

- (id)initWithUnsignedInt:(unsigned int)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value);
}

- (id)initWithLong:(long)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &value);
}

- (id)initWithUnsignedLong:(unsigned long)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &value);
}

- (id)initWithLongLong:(long long)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &value);
}

- (id)initWithUnsignedLongLong:(unsigned long long)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &value);
}

- (id)initWithFloat:(float)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value);
}

- (id)initWithDouble:(double)value {
    free(self);
    return (id)CFNumberCreate( kCFAllocatorDefault, kCFNumberDoubleType, &value );
}

- (id)initWithBool:(BOOL)value {
    free(self);
    return value ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

- (id)initWithInteger:(NSInteger)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &value);
}

- (id)initWithUnsignedInteger:(NSUInteger)value {
    free(self);
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &value);
}

#define TYPEIS(t)   (type == @encode(t)[0])

- (id)initWithBytes:(const void *)value objCType:(const char *)objCType {
    free(self);
    CFNumberType numberType = kCFNumberMaxType;
    char type = objCType[0];
    if (TYPEIS(char) || TYPEIS(unsigned char) || TYPEIS(BOOL) || TYPEIS(bool)) numberType = kCFNumberCharType;
    else if (TYPEIS(int) || TYPEIS(unsigned int)) numberType = kCFNumberIntType;
    else if (TYPEIS(short) || TYPEIS(unsigned short)) numberType = kCFNumberShortType;
    else if (TYPEIS(long) || TYPEIS(unsigned long)) numberType = kCFNumberLongType;
    else if (TYPEIS(long long) || TYPEIS(unsigned long long)) numberType = kCFNumberLongLongType;
    else if (TYPEIS(float)) numberType = kCFNumberFloatType;
    else if (TYPEIS(double)) numberType = kCFNumberDoubleType;
    else return nil; // Couldn't match to a number type
    return (id)CFNumberCreate(kCFAllocatorDefault, numberType, value);
}

#undef TYPEIS

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

#pragma mark - instance method prototypes

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

#pragma mark - NSDecimalNumberExtensions

- (NSDecimal)decimalValue { }

@end


@implementation __NSCFNumber

-(CFTypeID)_cfTypeID {
	return CFNumberGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

// TODO: Check whether numbers are still kept unique by CF
- (id)copyWithZone:(NSZone *)zone {
	return self;
}

-(NSString *)description {
	return (NSString *)CFCopyDescription(SELF);
}

// TODO: This needs re-writing when we get NSNumberFormatter
- (NSString *)descriptionWithLocale:(id)locale {
    SInt8 i8;
    SInt16 i16;
    SInt32 i32;
    SInt64 i64;
    Float32 f32;
    Float64 f64;
    CFStringRef string;
    
    // and here we should check for "special" number values eg. NaN, Inf
    
    // this is a bit long-winded, but I wanted to be sure...
    switch(CFNumberGetType((CFNumberRef)self)) {
        case kCFNumberSInt8Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt8Type, &i8);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%hhi"), i8 );
            break;
        case kCFNumberSInt16Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt16Type, &i16);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%hi"), i16 );
            break;
        case kCFNumberSInt32Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt32Type, &i32);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%i"), i32 );
            break;
        case kCFNumberSInt64Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberSInt64Type, &i64);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%lli"), i64 );
            break;
        case kCFNumberFloat32Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberFloat32Type, &f32);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%.3f"), f32 );
            break;
        case kCFNumberFloat64Type:
            CFNumberGetValue((CFNumberRef)self, kCFNumberFloat64Type, &f64);
            string = CFStringCreateWithFormat( kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%.8lf"), f64 );
            break;
            
        default:
            return @"";
    }
    PF_RETURN_TEMP(string)
}

- (void)getValue:(void *)value {
    CFNumberGetValue(SELF, CFNumberGetType(SELF), value);
}

// These assume that PureFoundation will only ever be built for 64bit
- (const char *)objCType {
	switch (CFNumberGetType(SELF)) {
		case kCFNumberCharType:
		case kCFNumberSInt8Type:
            return @encode(char);

		case kCFNumberShortType:
		case kCFNumberSInt16Type:
            return @encode(short);

		case kCFNumberIntType:
        case kCFNumberSInt32Type:
            return @encode(int);
            
		case kCFNumberLongType:
            return @encode(long);
            
		case kCFNumberCFIndexType:
		case kCFNumberNSIntegerType:
		case kCFNumberLongLongType:
        case kCFNumberSInt64Type:
            return @encode(long long);

		case kCFNumberFloatType:
        case kCFNumberFloat32Type:
            return @encode(float);

		case kCFNumberDoubleType:
		case kCFNumberFloat64Type:
        case kCFNumberCGFloatType:
            return @encode(double);
	}
	return "?"; 
}

- (char)charValue {
	char value;
	CFNumberGetValue(SELF, kCFNumberCharType, &value);
	return value;
}

- (unsigned char)unsignedCharValue {
	unsigned char value;
	CFNumberGetValue(SELF, kCFNumberCharType, &value);
	return value;	
}

- (short)shortValue {
	short value;
	CFNumberGetValue(SELF, kCFNumberShortType, &value);
	return value;
}

- (unsigned short)unsignedShortValue {
	unsigned short value;
	CFNumberGetValue(SELF, kCFNumberShortType, &value);
	return value;
}

- (int)intValue {
	int value;
	CFNumberGetValue(SELF, kCFNumberIntType, &value);
	return value;	
}

- (unsigned int)unsignedIntValue {
	unsigned int value;
	CFNumberGetValue(SELF, kCFNumberIntType, &value);
	return value;		
}

- (long)longValue {
	long value;
	CFNumberGetValue(SELF, kCFNumberLongType, &value);
	return value;		
}

- (unsigned long)unsignedLongValue {
	unsigned long value;
	CFNumberGetValue(SELF, kCFNumberLongType, &value);
	return value;		
}

- (long long)longLongValue {
	long long value;
	CFNumberGetValue(SELF, kCFNumberLongLongType, &value);
	return value;		
}

- (unsigned long long)unsignedLongLongValue {
	unsigned long long value;
	CFNumberGetValue(SELF, kCFNumberLongLongType, &value);
	return value;		
}

- (float)floatValue {
	float value;
	CFNumberGetValue(SELF, kCFNumberFloatType, &value);
	return value;			
}

- (double)doubleValue {
	double value;
	CFNumberGetValue(SELF, kCFNumberDoubleType, &value);
	return value;			
}

- (BOOL)boolValue {
    int value;
    CFNumberGetValue(SELF, kCFNumberIntType, &value);
    return value ? YES : NO;
}

- (NSInteger)integerValue {
	NSInteger value;
	CFNumberGetValue(SELF, kCFNumberNSIntegerType, &value);
	return value;			
}

- (NSUInteger)unsignedIntegerValue {
	NSUInteger value;
	CFNumberGetValue(SELF, kCFNumberNSIntegerType, &value);
	return value;		
}

- (NSString *)stringValue {
	return [self descriptionWithLocale:nil];
}

- (NSComparisonResult)compare:(NSNumber *)otherNumber {
	return CFNumberCompare(SELF, (CFNumberRef)otherNumber, NULL);
}

- (BOOL)isEqualToNumber:(NSNumber *)number {
	if (!number) return NO;
    return (self == number) || (CFNumberCompare(SELF, (CFNumberRef)number, NULL) == kCFCompareEqualTo);
}

- (NSDecimal)decimalValue {
    PF_TODO
}

@end


@implementation __NSCFBoolean

- (CFTypeID)_cfTypeID {
	return CFBooleanGetTypeID();
}

//Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (id)copyWithZone:(NSZone *)zone {
	return self; // because these are constants
}

- (const char *)objCType {
    return @encode(unsigned char);
}

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
- (NSInteger)integerValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (NSUInteger)unsignedIntegerValue { return (self == (id)kCFBooleanTrue) ? 1 : 0; }
- (BOOL)boolValue { return self == (id)kCFBooleanTrue; }

- (NSString *)stringValue { return self == (id)kCFBooleanTrue ? @"1" : @"0"; }
- (NSString *)description { return self == (id)kCFBooleanTrue ? @"1" : @"0"; }
- (NSString *)descriptionWithLocale:(id)locale {
     return self == (id)kCFBooleanTrue ? @"1" : @"0";
}

#pragma mark - NSDecimalNumberExtensions

- (NSDecimal)decimalValue { }

@end

#undef SELF
