/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFEnumerators.h
 *
 *	PFEnumerator, PFReverseEnumerator
 *
 *	Created by Stuart Crook on 14/03/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSValue.h"

/*
 *	Concrete subclasses of NSValue, each optomised to store a different type of 
 *	value (which could be overkill in some cases).
 */
@interface PFPointValue : NSValue {
	@public
	NSPoint _point;
}
@end

@interface PFRangeValue : NSValue {
	@public
	NSRange _range;
}
@end

@interface PFRectValue : NSValue {
	@public
	NSRect _rect;
}
@end

@interface PFSizeValue : NSValue {
	@public
	NSSize _size;
}
@end

@interface PFPointerValue : NSValue {
	@public
	void *_pointer;
}
@end

@interface PFObjectValue : NSValue {
	@public
	id _object;
}
@end

@interface PFStructValue : NSValue {
	@public
	const char *_type;
	NSUInteger _size;
	void *_struct;
}
@end
