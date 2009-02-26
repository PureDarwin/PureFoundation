/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSValue.m
 *
 *	NSValue, NSConcreteValue
 *
 *	Created by Stuart Crook on 28/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */


#import "NSValue.h"

/*
 *	Subclass of NSValue which does all the heavy lifting
 *
 *	I wonder if we don't need some others to deal with larger object sizes
 *		eg. NSConcreteStruct
 */
@interface NSConcreteValue : NSValue
{
	void *_type;
	void *_value;
}
@end




/************
 *	NSValue, which acts as a factory for NSConcreteValue objects
 ************/
@implementation NSValue

+(id)alloc
{
	// should this be locked to NSValue class only?
	if( self == [NSValue class] )
		return [NSConcreteValue alloc];
	return [super alloc];
}

// NSValueCreation
+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type
{
	return [[[NSValue alloc] initWithBytes: value objCType: type] autorelease];
}

+ (NSValue *)value:(const void *)value withObjCType:(const char *)type
{
	PF_HELLO("")
	return [NSValue valueWithBytes: value objCType: type];
}

// NSValueExtensionMethods
+ (NSValue *)valueWithNonretainedObject:(id)anObject
{
	return [NSValue valueWithBytes: (void *)anObject objCType: @encode(id)];
}

+ (NSValue *)valueWithPointer:(const void *)pointer
{
	return [NSValue valueWithBytes: (void *)pointer objCType: @encode(const void *)];
}


// NSValus instance methods (for the compiler)
- (void)getValue:(void *)value { }
- (const char *)objCType { return NULL; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

@end



/*
 *	NSValue subclass which actually stores passed values
 */
@implementation NSConcreteValue

// NSValueCreation
- (id)initWithBytes:(const void *)value objCType:(const char *)type
{
	PF_TODO
	
	if( self = [super init] )
	{
		// this is going to need our sizeof_objc_type code
		//size = sizeof(type);
		// if size > sizeof(void *), allocate storage space
		// save type
		// bytecopy across the value
	}
	return nil;
}

// NSValue instance methods
- (void)getValue:(void *)value 
{
	// look up type's size, then byte copy it into the destination
}

- (const char *)objCType
{
	// return it from storage
}

// NSValueExtension methods
- (id)nonretainedObjectValue
{
	
}

- (void *)pointerValue
{
	
}

- (BOOL)isEqualToValue:(NSValue *)value
{
	PF_HELLO("")
	
	if( self == value ) return YES;
	if( value == nil ) return NO;
	// compare type marker and contents
}

@end




