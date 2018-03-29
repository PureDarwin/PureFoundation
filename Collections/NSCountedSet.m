/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSCountedSet.m
 *
 *	NSCountedSet
 *
 *	Created by Stuart Crook on 18/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/** TODO:
 *		I've started work on NSCountedSet, which basically wraps access to a CFBag.
 */

#import "NSSet.h"

/*
 *	NSCountedSet
 *
 *	This appears to be a distince NSMutableSet subclass, which does not inherit from NSCFSet and is
 *	therefore not bridged.
 *
 *	Implements as many methods as NSCFSet, plus a few extras.
 *
 *	ivars: id _table; void *_reserved;  Store a CFMutableBag in _reserved
 */
@implementation NSCountedSet

/*
 *	All NSSet/NSMutableSet class methods
 */
+ (id)set { return [[[self alloc] init] autorelease]; }

+ (id)setWithCapacity:(NSUInteger)numItems { return [[[self alloc] initWithCapacity: numItems] autorelease]; }

+ (id)setWithObject:(id)object { return [[[self alloc] initWithObjects: &object count: 1] autorelease]; }

+ (id)setWithObjects:(id *)objects count:(NSUInteger)cnt 
{ 
	return [[[self alloc] initWithObjects: objects count: cnt] autorelease]; 
}

+ (id)setWithObjects:(id)firstObj, ... 
{
}

+ (id)setWithSet:(NSSet *)set { return [[[self alloc] initWithSet: set] autorelease]; }

+ (id)setWithArray:(NSArray *)array { return [[[self alloc] initWithArray: array] autorelease]; }


- (id)init
{
	PF_HELLO("")
	_reserved = CFBagCreateMutable( kCFAllocatorDefault, 0, &kCFTypeBagCallBacks );
	PF_RETURN_NEW(self)	
}

// from NSMutableSet
- (id)initWithCapacity:(NSUInteger)numItems // designated initializer
{
	PF_HELLO("")
	_reserved = CFBagCreateMutable( kCFAllocatorDefault, 0, &kCFTypeBagCallBacks );
	// apply bag capacity hint...
	PF_RETURN_NEW(self)	
}

// from NSSet
- (id)initWithArray:(NSArray *)array
{
	PF_HELLO("")
	PF_NIL_ARG(array)
	
	CFIndex count = [array count];
	if( count == 0 ) return [self init];
	
	void **ptr = NSZoneCalloc( nil, count, sizeof(id) );
	[array getObjects: (id *)ptr];
	
	CFBagRef temp = CFBagCreate( kCFAllocatorDefault, (const void **)ptr, count, &kCFTypeBagCallBacks );
	_reserved = CFBagCreateMutableCopy( kCFAllocatorDefault, 0, (CFBagRef)temp );
	
	CFRelease(temp);
	NSZoneFree( nil, ptr );
	
	PF_RETURN_NEW(self)
}

- (id)initWithSet:(NSSet *)set
{
	PF_TODO
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)flag
{
	PF_TODO
	
}

- (id)initWithObjects:(id *)objects count:(NSUInteger)cnt
{
	PF_TODO
	
}

- (id)initWithObjects:(id)firstObj, ... //NS_REQUIRES_NIL_TERMINATION;
{
	PF_TODO
	// copy most code from above
}






/*
 *	NSSet instance methods
 */
- (NSUInteger)count
{
	PF_HELLO("")
	return (NSUInteger)CFBagGetCount( (CFBagRef)_reserved );
}

- (id)member:(id)object
{
	PF_HELLO("")
	return (id)CFBagGetValue( (CFBagRef)_reserved, (const void *)object );
}

- (NSEnumerator *)objectEnumerator
{
	PF_TODO
	//return [[[PFEnumerator alloc] initWithBag: (CFBagRef)_reserved] autorelease];
}

/*
 *	NSExtendedSet instance methods
 */
- (NSArray *)allObjects
{
	PF_HELLO("")
	
	CFIndex count = [self count];
	if( count == 0 ) return [NSArray array];
	
	void **ptr = NSZoneCalloc( nil, count, sizeof(id) );
	CFBagGetValues( (CFBagRef)_reserved, (const void **)ptr );
	NSArray *array = (NSArray *)CFArrayCreate( kCFAllocatorDefault, (const void**)ptr, count, &kCFTypeArrayCallBacks );
	
	NSZoneFree( nil, ptr );
	PF_RETURN_TEMP(array)
}

- (id)anyObject
{
	PF_TODO
}

- (BOOL)containsObject:(id)anObject
{
	PF_HELLO("")
	return CFBagContainsValue( (CFBagRef)_reserved, (const void*)anObject );
}

- (NSString *)description
{
	PF_TODO
}

- (NSString *)descriptionWithLocale:(id)locale
{
	PF_TODO
}

- (BOOL)intersectsSet:(NSSet *)otherSet
{
	PF_TODO
}

- (BOOL)isEqualToSet:(NSSet *)otherSet
{
	PF_HELLO("probably doesn't work")
	
	if( self == otherSet ) return YES;
	if( otherSet == nil ) return NO;
	
	// hmmm... I'm sure that this won't work. compare to [otherSet allObjects] ???
	return CFEqual( (CFTypeRef)_reserved, (CFTypeRef)otherSet );
}

- (BOOL)isSubsetOfSet:(NSSet *)otherSet
{
	PF_TODO
}


- (void)makeObjectsPerformSelector:(SEL)aSelector
{
	PF_TODO
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument
{
	PF_TODO
}

- (NSSet *)setByAddingObject:(id)anObject //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_TODO
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_TODO
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_TODO
}

/*
 *	NSMutableSet instance methods
 */
- (void)addObject:(id)object
{
	PF_HELLO("")
	PF_NIL_ARG(object)
	
	CFBagAddValue( (CFMutableBagRef)_reserved, (const void*)object );
}

- (void)removeObject:(id)object
{
	PF_HELLO("")
	PF_NIL_ARG(object)
	
	CFBagRemoveValue( (CFMutableBagRef)_reserved, (const void *)object );
}


/*
 *	NSExtendedMutableSet instance methods
 */
- (void)addObjectsFromArray:(NSArray *)array
{
	PF_TODO
}

- (void)intersectSet:(NSSet *)otherSet
{
	PF_TODO
}

- (void)minusSet:(NSSet *)otherSet
{
	PF_TODO
}

- (void)removeAllObjects
{
	PF_HELLO("")
	CFBagRemoveAllValues( (CFMutableBagRef)_reserved );
}

- (void)unionSet:(NSSet *)otherSet
{
	PF_TODO
}

- (void)setSet:(NSSet *)otherSet
{
	PF_TODO
}


/*
 *	NSCountedSet specific instance methods
 */
- (NSUInteger)countForObject:(id)object
{
	PF_HELLO("")
	PF_NIL_ARG(object)
	
	return (NSUInteger)CFBagGetCountOfValue( (CFBagRef)_reserved, (const void *)object );
}



@end
