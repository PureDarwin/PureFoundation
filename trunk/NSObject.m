/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSObject.m
 *
 *	NSObject, _NSZombie_
 *
 *	Created by Stuart Crook on 08/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSObject.h"

#import "PureFoundation.h"

#import "NSAutoreleasePool.h"
#import "NSDebug.h"

#import <objc/runtime.h>
#import <objc/message.h>

//#import <Foundation/NSZone.h>

#import <stdio.h>	// we're going to be doing some diagnostic printing!
#include <pthread.h>

extern void _pfInitExceptions(void);

/*
 *	Objective-C objects' extra retain/release counts will be kept in an external CFMutableDictionary
 *	with their address as key and a simple CFIndex integer as key (which I think will ensure that it
 *	is not larger than a pointer).
 *
 *	GNUStep uses a NSMapTable. We could move to this at a later date -- we're going to have to implement
 *	the class at some point anyway since it was introcuded in 10.5 -- but doing it now would be kind-of
 *	circular: we need NSObject to make NSMapTable, and we need NSMapTable to make NSObject.
 *
 *	This static var holds a ref to the dictionary.
 */
static CFMutableDictionaryRef _PFRetainTable = nil;

pthread_mutex_t _pf_retm = PTHREAD_MUTEX_INITIALIZER;


extern NSZone _PFDefaultZone;


/*
 *	NSObject class implementation
 *
 *	For the most part, these methods are copied from <objc/Object.m> without change.
 */
@implementation NSObject

/* NSObject _object_ implementation */

/*
 *	Since NSObject+load appears to be the very first method called once the framework is linked, we
 *	will (eventually) use it to restore the bridge with CFLite.
 *
 *	This should really be flagged so it isn't called more than once.
 */
+ (void)load
{
	PF_HELLO("")

	_pfInitExceptions();
	
	/*
	 *	Create a mutable dictionary which can grow and doesn't retain keys or values */ 
	
}

/*
 *	+initialise is used here to allocate a CFMutableDictionary to hold extra retain counts.
 *
 *	One day we should really check to see if we're running under GC and not bother with this
 *	if we are. One day.
 *
 *	If it fails we will throw an exception and the entire framework will have to be abbandoned.
 */
+ (void)initialize
{
	PF_HELLO("")
	if( self == [NSObject class] )
	{
		_PFRetainTable = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, NULL, NULL );
		
	}
}

/*
 *	Object lifecycle
 */
+ (id)new
{
	PF_HELLO("")
	return [[self alloc] init];
}

// Object.m
//		replace malloc_default_zone with NSDefaultMallocZone() from NSZone.h ???
+ (id)alloc
{
	PF_HELLO("")
	//return (*_zoneAlloc)((Class)self, 0, malloc_default_zone());
	
	return NSAllocateObject( (Class)self, 0, NULL );
}

// based on Object.m +allocFromZone:(void *)z
+ (id)allocWithZone:(NSZone *)zone
{
	PF_HELLO("")
	//return (*_zoneAlloc)((Class)self, 0, zone);	// 'zone' was 'z'
	
	return NSAllocateObject( (Class)self, 0, zone ); // zone is currently ignored
}

- (id)init
{
	PF_HELLO("")
	return self;
}

/*
 *	Calls NSIncrementExtraRefCount().
 */
- (id)retain
{
	//PF_HELLO("")
	NSIncrementExtraRefCount(self);
	return self;
}

/*
 *	Calls NSDecrementExtraRefCountWasZero(). If it returns YES then we've decreased past the single
 *	retain, so we should dealloc.
 */
- (oneway void)release
{
	//PF_HELLO("")
	if( NSDecrementExtraRefCountWasZero(self) ) [self dealloc];
}

/*
 *	Invokes [NSAutoreleasePool add: self], meaning it's up to the NSAutoreleasePool class to keep track
 *	of the current thread, the objects added and the number of times they've been released
 */
- (id)autorelease
{
	PF_HELLO("")
	[NSAutoreleasePool addObject: self];
	return self;
}

/*
 *	Simple enough. Calls NSExtraRefCount() and returns its return +1
 */
- (NSUInteger)retainCount
{
	PF_HELLO("")
	NSUInteger count = NSExtraRefCount(self);
	return ++count;
}


- (void)dealloc
{
	PF_HELLO("")
	NSDeallocateObject(self);
}

- (void)finalize //AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
{
	PF_HELLO("")
	// nm on libobjc reports that it exports an _NSObject_finalize symbol... hook into this ???
	// it's something to do with GC, so can probably wait for a little while...
}


/*
 *	NSCopying
 *
 *	"This method exists so class objects can be used in situations where you need
 *	an object that conforms to the NSCopying protocol. For example, this method lets 
 *	you use a class object as a key to an NSDictionary object. You should not override 
 *	this method."
 */
+ (id)copyWithZone:(NSZone *)zone
{
	PF_TODO
	return nil;
}


+ (id)mutableCopyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	return [self copyWithZone: zone]; // override in mutable objects
}

- (NSZone *)zone
{
	// based on Object.m
	// is there an NS equivalent of malloc_zone_from_ptr we need to implement?
	//void *z = malloc_zone_from_ptr(self);
	//return (NSZone *)( z ? z : malloc_default_zone() ); // cast to NSZone* added
	return NULL;
}


/*
 *	Convinience methods for NSCopying (ignore the warnings)
 */
- (id)copy
{
	PF_HELLO("")
	return [self copyWithZone: nil];
}

- (id)mutableCopy
{
	PF_HELLO("")
	return [self mutableCopyWithZone: nil]; // override in mutable objects
}


/*
 *	Interaction with the runtime
 */
+ (Class)superclass
{
	PF_HELLO("")
	return class_getSuperclass(self); 
}

+ (Class)class
{
	PF_HELLO("")
	return self;
}





// based on Object.m +instanceRespondTo:
+ (BOOL)instancesRespondToSelector:(SEL)aSelector
{
	PF_HELLO("")
	// was (deprecated) return class_respondsToMethod((Class)self, aSelector);
	return class_respondsToSelector((Class)self, aSelector);
}

// based on Object.m +conformsTo:
+ (BOOL)conformsToProtocol:(Protocol *)protocol
{
	PF_HELLO("")
	Class class;
	for (class = self; class; class = class_getSuperclass(class))
    {
		if (class_conformsToProtocol(class, protocol)) return YES; // 'protocol' was 'aProtocolObj'
    }
	return NO;
}

- (IMP)methodForSelector:(SEL)aSelector
{
	PF_HELLO("")
	return class_getMethodImplementation( [self class], aSelector );
}

+ (IMP)instanceMethodForSelector:(SEL)aSelector
{
	PF_HELLO("")
	return class_getMethodImplementation( self, aSelector );
}

/* called by the runtime when an object recieves a selector it doesn't support */
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
	PF_HELLO("")
	[NSException raise: NSInvalidArgumentException format: @"Class %s does not recognise selector %s\n", class_getName([self class]), sel_getName(aSelector) ];
}

// - (id)forwardingTargetForSelector:(SEL)aSelector;		-- was commented out in header

-(id)forward:(SEL)selector :(marg_list)margs
{
	NSLog( @"<%s 0x%X> asked to forward:: %s", object_getClassName(self), self, sel_getName(selector) );
	return nil;
}
	
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	PF_HELLO("")
	// the default behaviour
	[self doesNotRecognizeSelector: [anInvocation selector]];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	PF_HELLO("")
	Method m = class_getInstanceMethod(isa, aSelector);
	const char *ptr = method_getTypeEncoding(m);
	//printf("Type encoding for %s on %s is %s\n", sel_getName(aSelector), class_getName(isa), ptr);
	return [NSMethodSignature signatureWithObjCTypes: ptr];
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector
{
	PF_HELLO("")
	Method m = class_getInstanceMethod(self, aSelector);
	const char *ptr = method_getTypeEncoding(m);
	//printf("Type encoding for %s on %s is %s\n", sel_getName(aSelector), class_getName(self), ptr);
	return [NSMethodSignature signatureWithObjCTypes: ptr];
}


+ (BOOL)isSubclassOfClass:(Class)aClass //AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER;
{
	PF_HELLO("")
	// I haven't actually given this implementation any thought. Sorry.
	Class cls = self;
	while (cls = class_getSuperclass(cls) )
	{
		if( cls == aClass ) return YES;
	}
	return NO;
}

/*
 *	"Dynamically provides an implementation for a given selector for a class method." "This method
 *	allows you to dynamically provides an implementation for a given selector. See resolveInstanceMethod: 
 *	for further discussion."
 */
+ (BOOL)resolveClassMethod:(SEL)sel //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_HELLO("")
	
	//printf("\tClass %s asked to resolve selector %s\n", class_getName([self class]), sel_getName(sel));
	return NO;
}

/*
 *	"Dynamically provides an implementation for a given selector for an instance method."
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	PF_HELLO("")

	//printf("\tClass %s asked to resolve selector %s\n", class_getName([self class]), sel_getName(sel));
	return NO;
}

// Object.m
- (Class)superclass
{
	PF_HELLO("")
	return class_getSuperclass(isa); // or [self class] instead of isa
}

// Object.m
- (Class)class
{
	PF_HELLO("")
	return (Class)isa; 
}

// Object.m
- (id)self
{
	PF_HELLO("")
	return self;
}


// Object.m
- (id)performSelector:(SEL)aSelector
{
	PF_HELLO("")
	if (aSelector)
		return objc_msgSend(self, aSelector); // equivalent to [self SEL];
	else
		//return [self error:_errBadSel, sel_getName(_cmd), aSelector];
		return nil; // should raise NSInvalidArgumentException instead
}

// Object.m
- (id)performSelector:(SEL)aSelector withObject:(id)object
{
	PF_HELLO("")
	if (aSelector)
		return objc_msgSend(self, aSelector, object);
	
	[NSException raise: NSInvalidArgumentException format: @"performSelector:withObject:"];
	return nil; // should raise NSInvalidArgumentException instead
}

// Object.m
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
{
	PF_HELLO("")
	if (aSelector)
		return objc_msgSend(self, aSelector, object1, object2);	// 'objectX' was 'objX'
	else
		//return [self error:_errBadSel, sel_getName(_cmd), aSelector]; // does NSObject impliment error: ???
		return nil; // should raise NSInvalidArgumentException instead
}

// ignored for now -- DO stuff...
- (BOOL)isProxy
{
	PF_HELLO("")
	return NO; // works for now because we haven't done DO so nothing's a proxy...
}

// based on Object.m -isKindOf:
- (BOOL)isKindOfClass:(Class)aClass
{
	PF_HELLO("")
	register Class cls = isa;
	do {
		if(cls == aClass) return YES;
	} while (cls = class_getSuperclass(cls));
	return NO;	
}

// based on Object.m -isMemberOf:
- (BOOL)isMemberOfClass:(Class)aClass
{
	PF_HELLO("")
	return isa == aClass;
}

// based on Object.m -conformsTo:
- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
	PF_HELLO("")
	return class_conformsToProtocol( isa, aProtocol );
}


// based on Object.m -respondsTo:
- (BOOL)respondsToSelector:(SEL)aSelector
{
	PF_HELLO("")
	return class_respondsToSelector( isa, aSelector );
}

// Object.m
- (BOOL)isEqual:(id)object
{
	PF_HELLO("")
	// should be re-written to use CFEquals ???
	return (object == self);	// 'object' was 'anObject'
}

/*
 *	Based on Object.m.
 *	Bridged classes can use CFHash, since CF no longer turns a call to it into 
 *	a -hash message
 */
- (NSUInteger)hash
{
	PF_HELLO("")
	return (NSUInteger)(((uintptr_t)self) >> 2);
}



- (NSString *)description
{
	PF_HELLO("")
	return [NSString stringWithFormat: @"<%s: 0x%X>", class_getName(isa), self];
}

// this version rreturns the class name and address
+ (NSString *)description
{
	PF_HELLO("")
	return [NSString stringWithFormat: @"<%s: 0x%X>", class_getName(self), self];
}


@end

/**
 *	NSCoderMethods category
 */
@implementation NSObject (NSCoderMethods)

// Object.m
+ (NSInteger)version
{
	return (NSInteger)class_getVersion((Class)self);
}

// Object.m
+ (void)setVersion:(NSInteger)aVersion
{
	class_setVersion((Class)self, aVersion); // cast aVersion to int ???
	//return self;
}

- (Class)classForCoder
{
	return nil; // ????
}

- (id)replacementObjectForCoder:(NSCoder *)aCoder
{
	return nil; // ???
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
	return nil; // ???
}

/* because this may be being called... */
-(CFTypeID)_cfTypeID
{
//	printf("-_cfTypeID called!\n");
	return 0; //_kCFRuntimeNotATypeID;
}

@end

/**
 *	NSDeprecatedMethods category
 */
@implementation NSObject (NSDeprecatedMethods)

// based on Object.m +poseAs:
+ (void)poseAsClass:(Class)aClass //DEPRECATED_IN_MAC_OS_X_VERSION_10_5_AND_LATER;
{
	class_poseAs(self, aClass); // 'aClass' was 'aFactory'
}

@end

/**
 *	Alloc / Dealloc function calls
 *
 *	These basically wrap calls to various CoreFoundation functions. Never-the-less, these should be used
 *	by all other "PureFoundation" objects in preference to the equivalent CF calls, because we're going to
 *	bake a whole load of special knowledge into them.
 */

/*
 *	NSAllocateObject() -- The single function tasked with allocating memory for obj-c objects.
 *
 *	In this version, class_getInstanceSize( class ) memory is allocated whether an object is bridged or not.
 *	This could change as I come back to study the whole bridging thing, but for now I just want an object
 *	memory managing wossname.
 */

id NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone)
{
	PF_HELLO("")

	// amount of memory to allocate
	NSUInteger size = extraBytes + class_getInstanceSize(aClass);

	// this version uses a function from the runtime
	void *object = NSZoneMalloc( nil, size );
	
	// set isa pointer to the obj-c class it now represents
	object_setClass( object, aClass );
	
	// return the allocated object
	return NSMakeCollectable((CFTypeRef)object);
}

/*
 *	Here we're assuming that the only objects we're dealing with are ones which were allocated by us
 *	in NSAllocateObject() above. This means that the memory should have been allocated from the default 
 *	allocator pool, which means we need only use it to free the object memory.
 *
 *	Of course, it's going to be far more complicated than that, but I can dream, can't I?
 */
extern void _CFRelease(CFTypeRef cf); // CFRuntime.c line #1101

void NSDeallocateObject(id object)
{
	PF_HELLO("")

	//fprintf(stderr, "PF: %s asked to deallocate 0x%X\n", getprogname(), object);
	
	if( object == nil ) return;
	
	if(NSZombieEnabled)
	{
		printf("Turning <%s 0x%X> into a zombie\n", object_getClassName(object), object);
		object_setClass(object, objc_getClass("_NSZombie_"));
	}
	else
	{
		//printf("Deallocating <%s 0x%X>\n", object_getClassName(object), object);
		
		//if( [object _cfTypeID] != 0 ) // free bridged objects via CF
		//	_CFRelease((CFTypeRef)object);
		//else
			NSZoneFree( nil, object );
	}
	//fprintf(stderr, "PF: leaving deallocate\n");
}

/*
 *	Return an exact copy of an object. The copy is exact, but the object does not inherit the original's
 *	retain count. Is this correct?
 */
id NSCopyObject(id object, NSUInteger extraBytes, NSZone *zone)
{
	if( object == nil ) return nil;
	
	NSUInteger size = class_getInstanceSize(object_getClass(object)) + extraBytes;
	void *ptr = NSZoneMalloc( zone, size );
	memcpy( ptr, (const void*)object, size );
	return NSMakeCollectable((CFTypeRef)ptr);
}

// "Returns YES if requestedZone is NULL, the default zone, or the zone in which anObject was 
//	allocated; otherwise NO."
BOOL NSShouldRetainWithZone(id anObject, NSZone *requestedZone)
{
	if( (requestedZone == NULL) || (requestedZone == NSDefaultMallocZone()) || (requestedZone == NSZoneFromPointer((void *)anObject)) ) 
		return YES;
	return NO;
}

/*
 *	Increase the extra ref count, which is kept in the _PFRetainTable (currently a CFMutableDictionary).
 *	To make this all lovely and threadsafe we're going to lock the process. One day.
 */
void NSIncrementExtraRefCount(id object)
{
	//PF_HELLO("")
	if( object == nil ) return;
	
	//if( _pf_IsMultiThreaded ) 
	pthread_mutex_lock(&_pf_retm);
	
	CFIndex count = (CFIndex)CFDictionaryGetValue( _PFRetainTable, object );
	
	printf("Retaining <%s 0x%X>, current count = %d\n", object_getClassName(object), object, count);

	
	
	CFDictionarySetValue( _PFRetainTable, object, (void *)(++count) );
	
	//if( _pf_IsMultiThreaded ) 
	pthread_mutex_unlock(&_pf_retm);
}

/*
 *	Read the extra ref count from _PFRetainTable. If this is zero, return YES. If it wasn't zero, take
 *	away one, save it back into the table, and return NO.
 */
BOOL NSDecrementExtraRefCountWasZero(id object)
{
	//PF_HELLO("")
	if( object == nil ) return NO; // get this simple case out the way quickly
	
	//if( _pf_IsMultiThreaded ) 
	pthread_mutex_lock(&_pf_retm);
		
	CFIndex count = (CFIndex)CFDictionaryGetValue( _PFRetainTable, object );
	
	printf("Releasing <%s 0x%X>, current count = %d\n", object_getClassName(object), object, count);

	if( count != 0 ) CFDictionarySetValue( _PFRetainTable, object, (void *)(--count) );
	
	//if( _pf_IsMultiThreaded ) 
	pthread_mutex_unlock(&_pf_retm);

	return (count == 0) ? YES : NO;
}

/*
 *	Report the objects current retain count. This is the number _above_ the initial expected single
 *	object retain -- which doesn't actually exist anywhere. So if an object hasn't been extra-retained
 *	-- through NSIncrementExtraRefCount() -- it 1) will have an extra retain count of 0, and 2) will
 *	not have an entry in _PRRetainTable... which means that the CFDictionaryGetValue() call below will
 *	return NULL (0), which is the correct answer.
 *
 *	I think.
 */
NSUInteger NSExtraRefCount(id object)
{
	//PF_HELLO("")
	
	NSUInteger count = (NSUInteger)CFDictionaryGetValue( _PFRetainTable, object );

	return count;
}

/*
 *	_NSZombie_ (which should really be defined in CF)
 */
@interface _NSZombie_
{ Class isa; }
@end

@implementation _NSZombie_
- (id)retain 
{ 
	fprintf(stderr, "<_NSZombie_ 0x%X> in %s sent -retain\n", self, getprogname()); 
	return self; 
}

- (void)release 
{ 
	fprintf(stderr, "<_NSZombie_ 0x%X> in %s sent -release\n", self, getprogname()); 
}

- (id)autorelease 
{ 
	fprintf(stderr, "<_NSZombie_ 0x%X> in %s sent -release\n", self, getprogname()); 
	return self; 
}

- (id)forward:(SEL)sel :(marg_list)margs 
{ 
	fprintf(stderr, "<_NSZombie_ 0x%X> in %s sent '%s'\n", self, getprogname(), sel_getName(sel)); 
	return nil; 
}

@end
