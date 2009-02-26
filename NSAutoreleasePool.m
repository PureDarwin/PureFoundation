/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSAutoreleasePool.m
 *
 *	NSAutoreleasePool
 *
 *	Created by Stuart Crook on 24/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSAutoreleasePool.h"

#import <objc/runtime.h>

/*
 *	Pointer to currently-active autorelease pool. Once we've got around to doing threads, we will
 *	either start storing this info in the individual thread's dictionary, or use this variable to
 *	store a dictionary of pools keyed on thread id
 */
static NSAutoreleasePool *_PFCurrentPool = nil;

/*
 *	Function passed to CFDictionaryApplyFunction and in turn passed each key-value pair it contains.
 *	It checks to see how many releases an object requires, checks this is at or below its current
 *	retainCount, and then calls -release that many times.
 *
 *	Nothing happens to the objects after that. The dictionary is set up not to retain any of them, so
 *	it's assumed that these references to them will just evaporates when it is released.
 *
 *	Also, no checks are made to see whether the key object is actually valid.
 */
static void _PFDrain(const void *key, const void *value, void *context)
{
	//printf("drain callback, key = 0x%X, value = 0x%X ... ", key, value);
	NSUInteger releaseCount = value;
	NSUInteger retainCount = [(id)key retainCount];
	//printf("object %@ at 0x%X, releaseCount = %u, retainCount = %u ... ", key, key, releaseCount, retainCount);
	if( releaseCount > retainCount ) releaseCount = retainCount;
	while ( releaseCount-- ) [(id)key release];
	//printf("finished releasing\n");
}


@implementation NSAutoreleasePool

/*
 *	We will use the instance variables in the following way:
 *		_reserved2 -> the previous NSAutoreleasePool
 *		_reserved3 -> this pools dictionary of objects
 */


/*
 *	Called by each new autorelease pool from their -init method to set them as the main pool for the
 *	current thread. Returns the existing pool, which they should hold on to.
 */
+(NSAutoreleasePool *)__hello:(NSAutoreleasePool *)pool
{
	PF_HELLO("")
	
	NSAutoreleasePool *temp = _PFCurrentPool;
	_PFCurrentPool = pool;
	return temp;
}


/*
 *	Called by the -drain (or should that be -dealloc) of each pool to get itself removed from duty as
 *	the current autorelease pool. It passes back the pointer to the pool which it replaced when it
 *	was -init'd. This could be nil, if this was the first pool created for this thread.
 */
+(void)__goodbye:(NSAutoreleasePool *)pool
{
	PF_HELLO("")
	
	_PFCurrentPool = pool;
}


/*
 *	Add anObject to the current pool for the current thread. This is what the basic definition of
 *	-autorelease does.
 */
+ (void)addObject:(id)anObject
{
	PF_HELLO("")
	
	//printf("pool asked to add <%s 0x%X>\n", class_getName(*(Class *)anObject), anObject);
	
	if( anObject == nil ) return;
	
	NSAutoreleasePool *pool = _PFCurrentPool;
	
	if( pool != nil )
		[pool addObject: anObject];
	else
		PF_DEBUG("\tThere is no current autorelease pool.\n");
}



/*
 *	Initialise the pool by setting it as the current pool for this thread. We'll lazy-create the dictionary
 *	used to store release counts the first time we need to store an object.
 */
-(id)init
{
	PF_HELLO("")
	
	if( self = [super init] )
	{
		_reserved2 = [NSAutoreleasePool __hello: self];
		_reserved3 = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, NULL, NULL );
	}
	return self;
}

/*
 *	Add anObject to the dictionary maintained by this pool, which we shall store in _reserved3
 */
- (void)addObject:(id)anObject
{
	PF_HELLO("")
	
	if( anObject == nil ) return;
	
	/*	Quickly check on the contents of the pool dictionary */
	NSUInteger count = (NSUInteger)CFDictionaryGetCount(_reserved3);
	PF_DEBUG_F("\tAutorelease pool contains %d objects.\n", count)
	
	/*	Retrieve the count of the number of times anObject has alread been added to the autorelease 
		pool. If it has never been added then this will return NULL, which is also correct */
	count = (NSUInteger)CFDictionaryGetValue( _reserved3, anObject );

	/*	Set the value at key anObject to count+1. Will work whether the object has been autoreleased
		before or not */
	CFDictionarySetValue( (CFMutableDictionaryRef)_reserved3, (const void *)anObject, (const void *)(++count) );
	//PF_DEBUG("leaving -addObject:")
}

/*
 *	#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
 *
 *	For now, under managed memory, release each of the stored objects.
 */
- (void)drain
{
	PF_HELLO("")
	
	/*	Say __goodbye to the NSAutoreleasePool class, which will replace this pool with whichever pool
	 we were passed when we said hello. Then zero _reserved2 for good measure. */
	[NSAutoreleasePool __goodbye: _reserved2];
	_reserved2 = nil;
	
	NSUInteger count = (NSUInteger)CFDictionaryGetCount( (CFDictionaryRef)_reserved3 );

	//printf("\tAutorelease pool contains %d objects.\n", count);

	// apply the _PFDrain function to each object in the dictionary/pool
	if( count != 0 )
		CFDictionaryApplyFunction( (CFDictionaryRef)_reserved3, _PFDrain, NULL );
}

/*
 *	Autorelease pool dealloc
 */
-(void)dealloc
{
	PF_HELLO("")
	
	// free the dictionary with CFRelease
	[(id)_reserved3 release];
	_reserved3 = nil;
	
	[super dealloc];
}

/*
 *	Calls -drain to release all of the stored objects, then deallocate the pool, since the way
 *	-retain is patched a pool can only ever be retained once.
 */
-(void)release
{
	PF_HELLO("")
	[self drain];
	[super release];	// which will call dealloc
}

/*
 *	Raise an exception
 */
-(id)retain
{
	// raise an exception... better find out which one
	return self; // and don't do this
}

@end



@implementation NSAutoreleasePool (NSAutoreleasePoolDebugging)

+ (void)enableRelease:(BOOL)enable { }
// Enables or disables autorelease pools; that is, whether or
// not the autorelease pools send the -release message to their
// objects when each pool is released. This message affects only
// the pools of the autorelease pool stack of the current thread
// (and any future pools in that thread). The "default default"
// value can be set in the initial environment when a program
// is launched with the NSEnableAutoreleasePool environment
// variable (see notes at the top of this file) -- as thread
// pool-stacks are created, they take their initial enabled
// state from that environment variable.

+ (void)showPools { }
// Displays to stderr the state of the current thread's
// autorelease pool stack.

+ (void)resetTotalAutoreleasedObjects { }
+ (NSUInteger)totalAutoreleasedObjects { return 0; }
// Returns the number of objects autoreleased (in ALL threads,
// currently) since the counter was last reset to zero with
// +resetTotalAutoreleasedObjects.

+ (void)enableFreedObjectCheck:(BOOL)enable { }
// Enables or disables freed-object checking for the pool stack
// of the current thread (and any future pools in that thread).
// When enabled, an autorelease pool will call the function
// _NSAutoreleaseFreedObject() when it is about to attempt to
// release an object that the runtime has marked as freed (and
// then it doesn't attempt to send -release to the freed storage).
// The pointer to the freed storage is passed to that function.
// The "default default" value can be set in the initial
// environment when a program is launched with the
// NSAutoreleaseFreedObjectCheckEnabled environment variable
// (see notes at the top of this file) -- as thread pool-stacks
// are created, they take their initial freed-object-check state
// from that environment variable.

+ (NSUInteger)autoreleasedObjectCount { return 0; }
// Returns the total number of autoreleased objects in all pools
// in the current thread's pool stack.

+ (NSUInteger)topAutoreleasePoolCount { return 0; }
// Returns the number of autoreleased objects in top pool of
// the current thread's pool stack.

+ (NSUInteger)poolCountHighWaterMark { return 0; }
+ (void)setPoolCountHighWaterMark:(NSUInteger)count { }
// Sets the pool count high water mark for the pool stack of
// the current thread (and any future pools in that thread). When
// 'count' objects have accumulated in the top autorelease pool,
// the pool will call _NSAutoreleaseHighWaterLog(), which
// generates a message to stderr. The number of objects in the
// top pool is passed as the parameter to that function. The
// default high water mark is 0, which disables pool count
// monitoring. The "default default" value can be set in the
// initial environment when a program is launched with the
// NSAutoreleaseHighWaterMark environment variable (see notes at
// the top of this file) -- as thread pool-stacks are created,
// they take their initial high water mark value from that
// environment variable. See also +setPoolCountHighWaterResolution:.

+ (NSUInteger)poolCountHighWaterResolution { return 0; }
+ (void)setPoolCountHighWaterResolution:(NSUInteger)res { }
// Sets the pool count high water resolution for the pool stack of
// the current thread (and any future pools in that thread). A
// call to _NSAutoreleaseHighWaterLog() is generated every multiple
// of 'res' objects above the high water mark. If 'res' is zero
// (the default), only one call to _NSAutoreleaseHighWaterLog() is
// made, when the high water mark is reached. The "default default"
// value can be set in the initial environment when a program is
// launched with the NSAutoreleaseHighWaterResolution environment
// variable (see notes at the top of this file) -- as thread
// pool-stacks are created, they take their initial high water
// resolution value from that environment variable. See also
// +setPoolCountHighWaterMark:.

@end
