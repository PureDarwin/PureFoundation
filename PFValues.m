/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFEnumerators.h
 *
 *	PFEnumerator, PFReverseEnumerator
 *
 *	Created by Stuart Crook on 14/03/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "PFValues.h"

/*
 *	Each of these classes implements only the methods specific to their 
 *	particular payload, inheriting the general case versions from NSValue
 */

@implementation PFPointValue

- (const char *)objCType { return @encode(NSPoint); }

- (void)getValue:(void *)value { *(NSPoint *)value = _point; }

- (NSPoint)pointValue { return _point; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFPointValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_point = _point;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation PFRangeValue

- (const char *)objCType { return @encode(NSRange); }

- (void)getValue:(void *)value { *(NSRange *)value = _range; }

- (NSRange)rangeValue { return _range; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFRangeValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_range = _range;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation PFRectValue

- (const char *)objCType { return @encode(NSRect); }

- (void)getValue:(void *)value { *(NSRect *)value = _rect; }

- (NSRect)rectValue { return _rect; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFRectValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_rect = _rect;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation PFSizeValue

- (const char *)objCType { return @encode(NSSize); }

- (void)getValue:(void *)value { *(NSSize *)value = _size; }

- (NSSize)sizeValue { return _size; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFSizeValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_size = _size;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation PFPointerValue

- (const char *)objCType { return @encode(void *); }

- (void)getValue:(void *)value { *(uintptr_t *)value = (uintptr_t)_pointer; } // does this make sense?

- (void *)pointerValue { return _pointer; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFPointerValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_pointer = _pointer;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation PFObjectValue

- (const char *)objCType { return @encode(id); }

- (void)getValue:(void *)value { *(id *)value = _object; }

- (id)nonretainedObjectValue { return _object; }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFObjectValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_object = _object;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end

@implementation PFStructValue

- (const char *)objCType { return (const char *)_type; }

- (void)getValue:(void *)value { memcpy(value, _struct, _size); }

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PFStructValue *copy = NSAllocateObject([self class], 0, nil);
	copy->_type = _type;
	copy->_size = _size;
	copy->_struct = _struct;
	return copy;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end
