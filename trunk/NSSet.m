/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSSet.m
 *
 *	NSSet, NSMutableSet, NSCFSet
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSSet.h>
#import "PureFoundation.h"
#import "PFEnumerator.h"

//#import "../CF-476.15.patched/CFSet.h"


/*
 *	I though this would be a simple(-ish) trial of everything I've learnt so far about creating these
 *	bridged classes
 */

/*
 *	Declare the interface to our bridged NSCFSet class
 */
@interface NSCFSet : NSMutableSet
@end

/*
 *	The dummy to act as one of these set objects when passed from +alloc to -init
 */
static Class _PFNSCFSetClass = nil;
static Class _PFNSCFMutableSetClass = nil;

/*
 *	macros to check the set's mutability
 */
extern bool _CFSetIsMutable( CFSetRef set );

#define PF_CHECK_SET(set) BOOL isMutable; \
	if( set == (id)&_PFNSCFSetClass ) isMutable = NO; \
	else if( set == (id)&_PFNSCFMutableSetClass ) isMutable = YES; \
	else { isMutable = _CFSetIsMutable((CFSetRef)set); [set autorelease]; }

#define PF_RETURN_SET_INIT if( isMutable == YES ) { [self autorelease]; self = (id)CFSetCreateMutableCopy( kCFAllocatorDefault, 0, (CFSetRef)self ); } \
	PF_RETURN_NEW(self)

#define PF_CHECK_SET_MUTABLE(set) if( !_CFSetIsMutable((CFSetRef)set) ) \
	[NSException raise: NSInternalInconsistencyException format: [NSString stringWithCString: "Attempting mutable set op on a static NSSet" encoding: NSUTF8StringEncoding]];


/*
 *	Implimentation of NSSet, which included only class methods and the intance methods declared in its
 *	@interface
 */
@implementation NSSet

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSSet class] )
		_PFNSCFSetClass = objc_getClass("NSCFSet");
}

/*
 *	As with the +alloc methods of other non-instantiable bridged classes, this calls the bridged
 *	class's +alloc
 */
+(id)alloc
{
	PF_HELLO("")
	if( self == [NSSet class] )
		return (id)&_PFNSCFSetClass;
	return [super alloc];
}

/*
 *	@interface NSSet (NSSetCreation)
 */
+ (id)set
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	CFSetRef set = CFSetCreate( kCFAllocatorDefault, NULL, 0, NULL );
	PF_RETURN_TEMP(set)
}

+ (id)setWithObject:(id)object
{
	PF_HELLO("")
	return [[[self alloc] initWithObjects: &object count: 1] autorelease];
}

+ (id)setWithObjects:(id *)objects count:(NSUInteger)cnt
{
	PF_HELLO("")
	return [[[self alloc] initWithObjects: objects count: cnt] autorelease];
}

+ (id)setWithObjects:(id)firstObj, ... //NS_REQUIRES_NIL_TERMINATION
{
	PF_HELLO("")
	
	id *objects;
	id *t_ptr;
	id temp;
	
	if( firstObj == nil )
		return [[[self alloc] init] autorelease];
	
	va_list args;
	va_start( args, firstObj );
	
	// count the number of args passed
	NSUInteger count = 1;
	while( (temp = va_arg( args, id )) != nil ) count++;
	
	if( count == 1 )
	{
		objects = &firstObj;
		//return [[[self alloc] initWithObjects: &firstObj count: 1] autorelease];
	}
	else
	{
		objects = calloc( count, sizeof(id) );
		t_ptr = objects;
		*t_ptr++ = firstObj;
		va_start( args, firstObj );
		while( (temp = va_arg( args, id )) != nil ) *t_ptr++ = temp;
	}
	
	temp = (id)CFSetCreate( kCFAllocatorDefault, (const void **)objects, count, &_PFCollectionCallBacks );
	
	if( count != 1 ) free( objects );
	va_end( args );

	PF_RETURN_TEMP(temp)
}

+ (id)setWithSet:(NSSet *)set
{
	PF_HELLO("")
	return [[[self alloc] initWithSet: set] autorelease];
}

+ (id)setWithArray:(NSArray *)array
{
	PF_HELLO("")
	return [[[self alloc] initWithArray: array] autorelease];
}


/*
 *	Instance methods. Compiler-friendly dummies, since NSSet is never instantiated.
 */
- (NSUInteger)count
{
	return 0;
}

- (id)member:(id)object
{
	return nil;
}

- (NSEnumerator *)objectEnumerator
{
	return nil;
}

/**	NSCopying COMPLIANCE **/

/*
 *	Return nil, because NSString should never be instatitated
 */
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

/** NSMutableCopying COMPLIANCE **/

/*
 *	Create an NSCFMutableString
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return nil;
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

/** NSFastEnumeration compliance **/
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	return 0;
}

@end



/*
 *	Implimentation of NSMutableSet
 */
@implementation NSMutableSet

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSMutableSet class] )
		_PFNSCFMutableSetClass = objc_getClass("NSCFSet");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSMutableSet class] )
		return (id)&_PFNSCFMutableSetClass;
	return [super alloc];
}

- (NSString *)descriptionWithLocale:(id)locale
{
	PF_TODO
	
}

/*
 *	NSMutableSet-specific creation method
 */
+ (id)set
{
	PF_HELLO("")
	CFMutableSetRef mset = CFSetCreateMutable( kCFAllocatorDefault, 0, &_PFCollectionCallBacks );
	PF_RETURN_TEMP(mset)
}

+ (id)setWithCapacity:(NSUInteger)numItems
{
	PF_HELLO("")
	//return [[[self alloc] initWithCapacity: numItems] autorelease];
	CFMutableSetRef mset = CFSetCreateMutable( kCFAllocatorDefault, 0, &_PFCollectionCallBacks );
	// set capacity hint...
	PF_RETURN_TEMP(mset)
}

/*
 *	We repeate this definition because va_args are a pain
 */
+ (id)setWithObjects:(id)firstObj, ... //NS_REQUIRES_NIL_TERMINATION
{
	PF_HELLO("")
	
	id *objects;
	id *t_ptr;
	id temp;
	
	if( firstObj == nil )
		return [[[self alloc] init] autorelease];
	
	va_list args;
	va_start( args, firstObj );
	
	// count the number of args passed
	NSUInteger count = 1;
	while( (temp = va_arg( args, id )) != nil ) count++;
	
	if( count == 1 )
	{
		objects = &firstObj;
		//return [[[self alloc] initWithObjects: &firstObj count: 1] autorelease];
	}
	else
	{
		objects = calloc( count, sizeof(id) );
		t_ptr = objects;
		*t_ptr++ = firstObj;
		va_start( args, firstObj );
		while( (temp = va_arg( args, id )) != nil ) *t_ptr++ = temp;
	}
	
	temp = (id)CFSetCreate( kCFAllocatorDefault, (const void **)objects, count, &_PFCollectionCallBacks );
	CFMutableSetRef mset = CFSetCreateMutableCopy( kCFAllocatorDefault, 0, (CFSetRef)temp );
	[temp release];
	
	if( count != 1 ) free( objects );
	va_end( args );
	
	PF_RETURN_TEMP(mset)
}

/*
 *	I'm not sure whether the below should be re-implemented to return mutable NSCFSets
 *
 *	As an experiment we'll let these inherit the NSSet implementation
 */
//+ (id)set;
//+ (id)setWithObject:(id)object;
//+ (id)setWithObjects:(id *)objects count:(NSUInteger)cnt;
//+ (id)setWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
//+ (id)setWithSet:(NSSet *)set;
//+ (id)setWithArray:(NSArray *)array;

/*
 *	Instance methods expected by the compiler
 */
- (void)addObject:(id)object { }
- (void)removeObject:(id)object { }

@end



/*
 *	NSCFSet implimentation
 */
@implementation NSCFSet

/*
 *	Called by NSString and NSMutableString +alloc methods. Returns the _PFNSCFStringClass dummy, so that
 *	the impending -init... methods can be correctly delivered. These then replace it with newly-allocated
 *	CFString objects
 */
+(id)alloc
{
	PF_HELLO("")
	//PF_DEBUG_F("_PFNSCFSetClass = %d\n", _PFNSCFSetClass);
	//return (id)(&_PFNSCFSetClass);
	return nil;
}


/*
 *	Undocumented method used by Apple to support bridging
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFSetGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *	See NSArray.h, -[NSCFArray countByEnumeratingWithState:...] for the gory details
 *
 *	This actually points to its _count var, which should also do the trick
 */
#define PF_SET_MO 24

/*
 *	NSFastEnumeration support. Based on example code from
 *		http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html
 *
 *	A dictionary enumerates over its keys
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	PF_HELLO("")
	
	CFIndex count = CFSetGetCount( (CFSetRef)self );

	//printf("-- enumerate: state = %u, count = %u\n", state->state, count);

	NSUInteger num = count - state->state;	// 0 if 1st time through an empty array, or at end
	// of a full one
	if( num != 0 )
	{
		num = (len < num) ? len : num; // number of items to copy
		
		// optomised for first reads of small sets
		if( (state->state == 0) && (num <= count) )
			CFSetGetValues( (CFSetRef)self, (const void**)stackbuf );
		else
		{
			// because of course, like CFDictionary, CFSet is awkward and does not allow you to 
			//	get only a range keys...
			void *buffer = calloc( count, sizeof(id) );
			CFSetGetValues( (CFSetRef)self, (const void**)buffer );
			void *t_buffer = buffer + (state->state * sizeof(id));
			memcpy( stackbuf, t_buffer, (num * sizeof(id)) ); // should be 16 at most, so could use pointers
			free( buffer );
		}
		
		// set the return values
		state->state += num;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = (unsigned long *)((NSUInteger)self + PF_SET_MO); // see above
		//printf("Is %u %u + %u?\n", state->mutationsPtr, self, PF_SET_MO);
	}
	return num;
}


-(NSString *)description
{
	PF_HELLO("")
	//PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
	return CFCopyDescription((CFTypeRef)self);
}

/*
 *	NSSet creation methods
 */
- (id)init
{
	PF_HELLO("")
	PF_CHECK_SET(self)
	
	if( isMutable == NO )
		self = (id)CFSetCreate( kCFAllocatorDefault, NULL, 0, &_PFCollectionCallBacks );
	else
		self = (id)CFSetCreateMutable( kCFAllocatorDefault, 0, &_PFCollectionCallBacks );
	
	PF_RETURN_NEW(self)
}

- (id)initWithObjects:(id *)objects count:(NSUInteger)cnt
{
	PF_HELLO("")
	PF_CHECK_SET(self)
	
	self = (id)CFSetCreate( kCFAllocatorDefault, (const void**)objects, cnt, &_PFCollectionCallBacks );
	
	PF_RETURN_SET_INIT
}

- (id)initWithObjects:(id)firstObj, ... //NS_REQUIRES_NIL_TERMINATION;
{
	PF_HELLO("")
	
	id *objects;
	id *t_ptr;
	id temp;
	
	if( firstObj == nil ) return [self init];
	
	va_list args;
	va_start( args, firstObj );
	
	// count the number of args passed
	NSUInteger count = 1;
	while( (temp = va_arg( args, id )) != nil ) count++;
	
	if( count == 1 )
	{
		objects = &firstObj;
	}
	else
	{
		objects = calloc( count, sizeof(id) );
		
		t_ptr = objects;

		*t_ptr++ = firstObj;
		va_start( args, firstObj );

		while( (temp = va_arg( args, id )) != nil )
			*t_ptr++ = temp;
	}
	
	PF_CHECK_SET(self)
	
	self = (id)CFSetCreate( kCFAllocatorDefault, (const void**)objects, count, &_PFCollectionCallBacks );
	
	if( count != 1 ) free( objects );
	va_end( args );
	
	PF_RETURN_SET_INIT
}

- (id)initWithSet:(NSSet *)set
{
	PF_HELLO("")
	PF_NIL_ARG(set)
	PF_CHECK_SET(self)
	
	if( isMutable == NO )
		self = (id)CFSetCreateCopy( kCFAllocatorDefault, (CFSetRef)set );
	else
		self = (id)CFSetCreateMutableCopy( kCFAllocatorDefault, 0, (CFSetRef)set );
	
	PF_RETURN_NEW(self)
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)flag
{
	PF_HELLO("")
	PF_NIL_ARG(set)
	
	if( flag == NO ) 
		return [self initWithSet: set]; // autorelease should be okay
	
	CFIndex count = [set count];
	if( count == 0 )
		return [self init];
	
	id *ptr = calloc( count, sizeof(id) );

	for( id object in set )
		*ptr++ = [object copyWithZone: nil];
	
	ptr -= count;
	
	PF_CHECK_SET(self)

	self = (id)CFSetCreate( kCFAllocatorDefault, (const void **)ptr, count, &_PFCollectionCallBacks );

	free( ptr );
	
	PF_RETURN_SET_INIT
}

- (id)initWithArray:(NSArray *)array
{
	PF_HELLO("")
	PF_NIL_ARG(array) // ???
	
	CFIndex count = [array count];
	if( count == 0 )
		return [self init]; // autorelease is okay
	
	// get values from the array
	id *ptr = calloc( count, sizeof(id) );
	[array getObjects: ptr];

	PF_CHECK_SET(self)
	
	self = (id)CFSetCreate( kCFAllocatorDefault, (const void**)ptr, count, &_PFCollectionCallBacks );
	
	free( ptr );
	
	PF_RETURN_SET_INIT
}

/*
 *	NSMutableSet creation methods
 */
- (id)initWithCapacity:(NSUInteger)numItems
{
	PF_HELLO("")
	PF_CHECK_SET(self)
	
	if( isMutable == NO )
		[NSException raise: NSInternalInconsistencyException format: nil];
	
	self = (id)CFSetCreateMutable( kCFAllocatorDefault, 0, &_PFCollectionCallBacks );
	// use set capacity hint here...
	PF_RETURN_NEW(self)
}


/*
 *	NSSet instance methods
 */
- (NSUInteger)count
{
	PF_HELLO("")
	return (NSUInteger)CFSetGetCount( (CFSetRef)self );
}

- (id)member:(id)object
{
	PF_HELLO("")
	
	//id value;
	//if( CFSetGetValueIfPresent( (CFSetRef)self, (const void *)&object, (const void **)&value ) )
	//	return value;
	//else
	//	return nil;
	return (id)CFSetGetValue( (CFSetRef)self, (const void *)object );
}

- (NSEnumerator *)objectEnumerator
{
	PF_HELLO("")
	return [[[PFEnumerator alloc] initWithCFSet: self] autorelease];
}

/*
 *	NSExtendedSet instance methods
 */
- (NSArray *)allObjects
{
	PF_HELLO("")
	
	CFIndex count = [self count];
	if( count == 0 ) 
		return [NSArray array];

	void **ptr = calloc( count, sizeof(id) );
	CFSetGetValues( (CFSetRef)self, (const void **)ptr );
	
	NSArray *array = [NSArray arrayWithObjects: (const id*)ptr count: count]; // has been autoreleased
	free( ptr );
	return array;
}

- (id)anyObject
{
	PF_TODO
	
	NSUInteger count = CFSetGetCount((CFSetRef)self);
	if( count == 0 ) return nil;
	
	// Hmm... Given the functions CF give us, this is actually quite hard
	id *ptr = calloc(count, sizeof(id));
	CFSetGetValues((CFSetRef)self, (const void **)ptr);
	id randomishObject = *ptr;
	free(ptr);
	return randomishObject;
}

- (BOOL)containsObject:(id)anObject
{
	PF_HELLO("")
	PF_NIL_ARG(anObject)
	
	return CFSetContainsValue( (CFSetRef)self, (const void *)anObject );
}

- (BOOL)isEqualToSet:(NSSet *)otherSet
{
	PF_HELLO("")
	
	if( self == otherSet ) return YES;
	if( otherSet == nil ) return NO;
	
	return CFEqual( (CFTypeRef)self, (CFTypeRef)otherSet );
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
	PF_HELLO("")
	
	for( id object in self )
		[object performSelector: aSelector];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument
{
	PF_HELLO("")
	
	for( id object in self )
		[object performSelector: aSelector withObject: argument];
}


- (BOOL)intersectsSet:(NSSet *)otherSet
{
	PF_HELLO("")
	
	if( (otherSet == nil) || ([otherSet count] == 0) || (CFSetGetCount((CFSetRef)self) == 0) ) return NO;
	
	// we'll itterate over the otherSet and use CF calls on ourself
	for( id object in otherSet )
		if( CFSetContainsValue( (CFSetRef)self, (const void *)object ) ) return YES;
	
	return NO;
}


- (BOOL)isSubsetOfSet:(NSSet *)otherSet
{
	PF_HELLO("")
	
	if( [self isEqualToSet: otherSet] ) return YES;
	
	// this is going to be slowed because we have to check every object in reciever
	for( id object in self )
		if( [otherSet containsObject: object] == NO ) return NO;
	
	return YES;
}


- (NSSet *)setByAddingObject:(id)anObject //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_HELLO("")
	PF_NIL_ARG(anObject)
	
	CFIndex count = [self count];
	if( count == 0 ) 
		return [NSSet setWithObject: anObject];
	
	id *ptr = calloc( (count + 1), sizeof(id) );
	CFSetGetValues( (CFSetRef)self, (const void**)ptr );
	ptr[count] = anObject;

	CFSetRef set = CFSetCreate( kCFAllocatorDefault, (const void**)ptr, (count + 1), &kCFTypeSetCallBacks );
	
	free( ptr );
	PF_RETURN_TEMP(set)
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_HELLO("")
	PF_NIL_ARG(other)
	
	CFIndex count1 = CFSetGetCount((CFSetRef)self); //[self count];
	CFIndex count2 = [other count];
	CFSetRef set;
	
	if( count1 == 0 )
	{
		if( count2 == 0 ) 
			return [NSSet set]; // or set = new empty set
		else
			set = CFSetCreateCopy( kCFAllocatorDefault, (CFSetRef)other );
	}
	else 
	{
		if( count2 == 0 ) 
			set = CFSetCreateCopy( kCFAllocatorDefault, (CFSetRef)self );
		else
		{
			void **ptr1 = calloc( (count1 + count2), sizeof(id) );
			void **ptr2 = ptr1 + count1;
			
			CFSetGetValues( (CFSetRef)self, (const void**)ptr1 );
			// this only works if other is also an NSCFSet... check, and go via array if not
			CFSetGetValues( (CFSetRef)other, (const void**)ptr2 );
			
			set = CFSetCreate( kCFAllocatorDefault, (const void**)ptr1, (count1 + count2), &_PFCollectionCallBacks );
			
			free( ptr1 );
		}
	}
	
	PF_RETURN_TEMP(set)
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_HELLO("")
	PF_NIL_ARG(other)
	
	CFIndex count1 = CFSetGetCount((CFSetRef)self); //[self count];
	CFIndex count2 = [other count];
	CFSetRef set;
	
	if( count1 == 0 )
	{
		if( count2 == 0 ) 
			return [NSSet set]; // or set = new empty set
		else
			set = CFSetCreateCopy( kCFAllocatorDefault, (CFSetRef)other );
	}
	else 
	{
		if( count2 == 0 ) 
			set = CFSetCreateCopy( kCFAllocatorDefault, (CFSetRef)self );
		else
		{
			void **ptr1 = calloc( (count1 + count2), sizeof(id) );
			void **ptr2 = ptr1 + count1;
			
			CFSetGetValues( (CFSetRef)self, (const void**)ptr1 );
			[other getObjects: (id *)ptr2];
			
			set = CFSetCreate( kCFAllocatorDefault, (const void**)ptr1, (count1 + count2), &_PFCollectionCallBacks );
			
			free( ptr1 );
		}
	}
	
	PF_RETURN_TEMP(set)
}


/*
 *	NSMutableSet instance methods
 */
- (void)addObject:(id)object
{
	PF_HELLO("")
	PF_CHECK_SET_MUTABLE(self)
	
	CFSetAddValue( (CFMutableSetRef)self, (const void*)object );
}

- (void)removeObject:(id)object
{
	PF_HELLO("")
	PF_CHECK_SET_MUTABLE(self)

	CFSetRemoveValue( (CFMutableSetRef)self, (const void*)object );
}


/*
 *	NSExtendedMutableSet instance methods
 */
- (void)removeAllObjects
{
	PF_HELLO("")
	PF_CHECK_SET_MUTABLE(self)
	
	CFSetRemoveAllValues( (CFMutableSetRef)self );
}


- (void)addObjectsFromArray:(NSArray *)array
{
	PF_TODO
	PF_CHECK_SET_MUTABLE(self)
	
	if( array == nil ) return;
	
	for( id object in array )
		CFSetAddValue( (CFMutableSetRef)self, (const void *)object );
}


/*
 *	"Removes from the receiver each object that isn’t a member of another given set."
 */
- (void)intersectSet:(NSSet *)otherSet
{
	PF_TODO
	PF_CHECK_SET_MUTABLE(self)
	
	if( (otherSet == nil) || ([otherSet count] == 0) ) return [self removeAllObjects];
	
	CFMutableSetRef mset = CFSetCreateMutable( kCFAllocatorDefault, 0, NULL ); // don't want to retain
	
	// find all of the objects which are in self but not otherSet...
	for( id object in self )
		if( [otherSet containsObject: object] == NO )
			CFSetAddValue( (CFMutableSetRef)mset, (const void *)object );
	
	// ...and then remove them
	for( id object in (NSSet *)mset )
		CFSetRemoveValue( (CFMutableSetRef)self, (const void *)object );
	
	[(id)mset release];
}

/*
 *	"Removes from the receiver each object contained in another given set that is 
 *	present in the receiver."
 */
- (void)minusSet:(NSSet *)otherSet
{
	PF_TODO
	PF_CHECK_SET_MUTABLE(self)
	
	if( (otherSet == nil) || ([otherSet count] == 0) ) return;
	
	for( id object in otherSet )
		CFSetRemoveValue( (CFMutableSetRef)self, (const void *)object );
}


/*
 *	"Adds to the receiver each object contained in another given set that is not 
 *	already a member."
 */
- (void)unionSet:(NSSet *)otherSet
{
	PF_TODO
	PF_CHECK_SET_MUTABLE(self)
	
	if( (otherSet == nil) || ([otherSet count] == 0) ) return;
	
	for( id object in otherSet )
		CFSetAddValue( (CFMutableSetRef)self, (const void *)object );
}


- (void)setSet:(NSSet *)otherSet
{
	PF_HELLO("")
	PF_CHECK_SET_MUTABLE(self)

	CFSetRemoveAllValues( (CFMutableSetRef)self );

	// enumerate over other set, adding each value
	for( id object in otherSet )
		CFSetAddValue( (CFMutableSetRef)self, (const void *)object );
}

@end

