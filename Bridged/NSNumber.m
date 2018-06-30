/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSNumber.m
 *
 *	NSNumber
 *
 *	Created by Stuart Crook on 15/02/2009.
 */

#import "NSValue.h"
#import <objc/runtime.h> // for variable types

// NSNumber is decalred here in Foundation
// __NSCFNumber and __NSCFBoolean are implemented in CF

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
