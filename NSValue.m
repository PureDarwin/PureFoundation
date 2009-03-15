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
#import "PFValues.h"
#import "PFObjCTypeTools.h"

static Class _NSValueClass = nil;

/*
 *	NSValue, which acts as a factory for its concrete subclasses, which in this 
 *	implementation at least includes NSNumber/NSCFNumber objects
 */
@implementation NSValue

+(void)initialize
{
	if( self == [NSValue class] )
		_NSValueClass = objc_getClass("NSValue");
}

+(id)alloc
{
	if( self == [NSValue class] )
		return (id)&_NSValueClass;
	return [super alloc];
}

// NSValue instance methods (for the compiler). We should make these more meaningful.
- (void)getValue:(void *)value { }
- (const char *)objCType { return NULL; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone { return nil; }

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation NSValue (NSValueCreation)

+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type
{
	return [[(NSValue *)&_NSValueClass initWithBytes: value objCType: type] autorelease];
}

+ (NSValue *)value:(const void *)value withObjCType:(const char *)type
{
	return [[(NSValue *)&_NSValueClass initWithBytes: value objCType: type] autorelease];
}

/*
 *	Create the NSValue subclass for the given type. If the type is a number, return a
 *	CFNumber instead.
 */
- (id)initWithBytes:(const void *)value objCType:(const char *)type
{
	NSUInteger size;
	CFNumberType nType = 0;
	self = nil;
	
	if( (value == NULL) || (type == NULL) || (type[0] == '\0') ) return nil;

	type = pfenc_skip(type);

	switch (*type) {
		case _C_STRUCT_B: // could be an NSPoint, NSRange, NSSize or NSRect...
			if( 0 == strncmp(type, "{_NSPoint=", 10) )
			{
				self = NSAllocateObject([PFPointValue class], 0, nil);
				((PFPointValue *)self)->_point = *(NSPoint *)value;
				break;
			}
			else if( 0 == strncmp(type, "{_NSRange=", 10) )
			{
				self = NSAllocateObject([PFRangeValue class], 0, nil);
				((PFRangeValue *)self)->_range = *(NSRange *)value;
				break;
			}
			else if( 0 == strncmp(type, "{_NSSize=", 9) )
			{
				self = NSAllocateObject([PFSizeValue class], 0, nil);
				((PFSizeValue *)self)->_size = *(NSSize *)value;
				break;
			}
			else if( 0 == strncmp(type, "{_NSRect=", 9) )
			{
				self = NSAllocateObject([PFRectValue class], 0, nil);
				((PFRectValue *)self)->_rect = *(NSRect *)value;
				break;
			}

			// ...or just a normal struct
		case _C_ARY_B: // these are also stored in a PFStructValue
		case _C_UNION_B:
			self = NSAllocateObject([PFStructValue class], 0, nil);
			((PFStructValue *)self)->_type = pfenc_copy(type);
			pfenc_size_align(type, &size, NULL);
			void *ptr = malloc(size);
			memcpy(ptr, value, size);
			((PFStructValue *)self)->_size = size;
			((PFStructValue *)self)->_struct = ptr;
			break;
		
		case _C_ID:
			self = NSAllocateObject([PFObjectValue class], 0, nil);
			((PFObjectValue *)self)->_object = *(id *)value;
			break;
			
		case _C_PTR:
			self = NSAllocateObject([PFPointerValue class], 0, nil);
			((PFPointerValue *)self)->_pointer = (void *)value;
			break;

		// this needs to be expanded to cover all possible types...
		case _C_CHR: nType = kCFNumberSInt8Type; break;
		case _C_SHT: nType = kCFNumberSInt16Type; break;
		case _C_INT: nType = kCFNumberSInt32Type; break;
		case _C_LNG: nType = kCFNumberSInt32Type; break;
		case _C_LNG_LNG: nType = kCFNumberSInt64Type; break;
		case _C_FLT: nType = kCFNumberFloat32Type; break;
		case _C_DBL: nType = kCFNumberFloat64Type; break;
	}
	
	if(nType)
		self = (NSValue *)CFNumberCreate( kCFAllocatorDefault, nType, value);

	PF_RETURN_NEW(self)
}

@end

@implementation NSValue (NSValueExtensionMethods)

+ (NSValue *)valueWithNonretainedObject:(id)anObject
{
	PFObjectValue *new = NSAllocateObject([PFObjectValue class], 0, nil);
	new->_object = anObject;
	PF_RETURN_TEMP(new)
}

+ (NSValue *)valueWithPointer:(const void *)pointer
{
	PFPointerValue *new = NSAllocateObject([PFPointerValue class], 0, nil);
	new->_pointer = (void *)pointer;
	PF_RETURN_TEMP(new)
}

- (id)nonretainedObjectValue { return nil; }
- (void *)pointerValue { return NULL; }
- (BOOL)isEqualToValue:(NSValue *)value { return NO; }

@end

@implementation NSValue (NSValueGeometryExtensions)

+ (NSValue *)valueWithPoint:(NSPoint)point
{
	PFPointValue *new = NSAllocateObject([PFPointValue class], 0, nil);
	new->_point = point;
	PF_RETURN_TEMP(new)
}

+ (NSValue *)valueWithSize:(NSSize)size
{
	PFSizeValue *new = NSAllocateObject([PFSizeValue class], 0, nil);
	new->_size = size;
	PF_RETURN_TEMP(new)
}

+ (NSValue *)valueWithRect:(NSRect)rect
{
	PFRectValue *new = NSAllocateObject([PFRectValue class], 0, nil);
	new->_rect = rect;
	PF_RETURN_TEMP(new)
}

- (NSPoint)pointValue { return NSZeroPoint; }
- (NSSize)sizeValue { return NSZeroSize; }
- (NSRect)rectValue { return NSZeroRect; }

@end

@implementation NSValue (NSValueRangeExtensions)

+ (NSValue *)valueWithRange:(NSRange)range
{
	PFRangeValue *new = NSAllocateObject([PFRangeValue class], 0, nil);
	new->_range = range;
	PF_RETURN_TEMP(new)
}

- (NSRange)rangeValue { return NSMakeRange(0,0); }

@end
