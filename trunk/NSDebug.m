/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSDebug.m
 *
 *	Various debugging functions
 *
 *	Created by Stuart Crook on 13/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSDebug.h"

#import <objc/runtime.h>

/**	TODO:
 *		The more I think about, the more important it seems to get all of these
 *	implemented. Either that or patch gdb to work on Darwin. Or both.
 */


/* The environment component of this API
 
 The boolean- and integer-valued variables declared in this header,
 plus some values set by methods, read starting values from the
 process's environment at process startup.  This is mostly a benefit
 if you need to initialize these variables to some non-default value
 before your program's main() routine gets control, but it also
 allows you to change the value without modifying your program's
 source. (Variables can be set and methods called around specific
 areas within a program, too, of course.)
 
 The initialization from the environment happens very early, but may
 not have happened yet at the time of a +load method statically linked
 into an application (as opposed to one in a dynamically loaded module). 
 But as noted in the "Foundation Release Notes", +load methods that are
 statically linked into an application are tricky to use and are not
 recommended.
 
 Here is a table of the variables/values initialized from the environment
 at startup.  Some of these just set variables, others call methods to
 set the values.
 
 NAME OF ENV. VARIABLE		       DEFAULT	SET TO...
 NSDebugEnabled						NO		"YES"
 NSZombieEnabled					NO		"YES"
 NSDeallocateZombies				NO		"YES"
 NSHangOnUncaughtException			NO		"YES"
 
 NSEnableAutoreleasePool			 YES	"NO"
 NSAutoreleaseFreedObjectCheckEnabled	  NO	"YES"
 NSAutoreleaseHighWaterMark		  0	non-negative integer
 NSAutoreleaseHighWaterResolution	  0	non-negative integer
 
 */

/*
 *	Function called from +[NSObject load] to set up debugging according
 *	to the local environment
 */
void _pfDebugInit( void )
{
	NSDictionary *env = [[NSProcessInfo processInfo] environment];
	if( env != nil )
	{
		
		
		
		
	}
}

/****************	General		****************/

BOOL NSDebugEnabled = NO;
// General-purpose global boolean. Applications and frameworks
// may choose to do some extra checking, or use different
// algorithms, or log informational messages, or whatever, if
// this variable is true (ex: if (NSDebugEnabled) { ... }).

BOOL NSZombieEnabled = YES;
// Enable object zombies. When an object is deallocated, its isa
// pointer is modified to be that of a "zombie" class (whether or
// not the storage is then freed can be controlled by the
// NSDeallocateZombies variable). Messages sent to the zombie
// object cause logged messages and can be broken on in a debugger.
// The default is NO.

BOOL NSDeallocateZombies = NO;
// Determines whether the storage of objects that have been
// "zombified" is then freed or not. The default value (NO)
// is most suitable for debugging messages sent to zombie
// objects. And since the memory is never freed, storage
// allocated to an object will never be reused, either (which
// is sometimes useful otherwise).

BOOL NSHangOnUncaughtException = NO;
// If set to YES, causes the process to hang after logging the
// "*** Uncaught exception:" message. A backtrace can be gotten
// from the process with the 'sample' utility, or the process can
// be attached to with a debugger. The default is NO.

BOOL NSIsFreedObject(id anObject) { return NO; }
// Returns YES if the value passed as the parameter is a pointer
// to a freed object. Note that memory allocation packages will
// eventually reuse freed memory blocks to satisfy a request.
// NSZombieEnabled and NSDeallocateZombies can be used to prevent
// reuse of allocated objects.

/****************	Stack processing	****************/

void *NSFrameAddress(NSUInteger frame) { return NULL; }
void *NSReturnAddress(NSUInteger frame) { return NULL; }
// Returns the value of the frame pointer or return address,
// respectively, of the specified frame. Frames are numbered
// sequentially, with the "current" frame being zero, the
// previous frame being 1, etc. The current frame is the
// frame in which either of these functions is called. For
// example, NSReturnAddress(0) returns an address near where
// this function was called, NSReturnAddress(1) returns the
// address to which control will return when current frame
// exits, etc. If the requested frame does not exist, then
// NULL is returned. The behavior of these functions is
// undefined in the presence of code which has been compiled
// without frame pointers.

NSUInteger NSCountFrames(void) { return 0; }
// Returns the number of call frames on the stack. The behavior
// of this functions is undefined in the presence of code which
// has been compiled without frame pointers.

/****************	Autorelease pool debugging	****************/

// Functions used as interesting breakpoints in a debugger

// Called to log the "Object X of class Y autoreleased with no
// pool in place - just leaking" message.
void _NSAutoreleaseNoPool(void *object) 
{ 
	NSLog( @"*** Tried to autorelease object <%s 0x%X> with no pool in place.", class_getName([(id)object class]), object );
}

void _NSAutoreleaseFreedObject(void *freedObject) { }
// Called when a previously freed object would be released
// by an autorelease pool. See +enableFreedObjectCheck: below.

void _NSAutoreleaseHighWaterLog(NSUInteger count) { }
// Called whenever a high water mark is reached by a pool.
// See +setPoolCountHighWaterMark: below.


/****************	Allocation statistics	****************/

// The statistics-keeping facilities generate output on various types of
// events. Currently, output logs can be generated for use of the zone
// allocation functions (NSZoneMalloc(), etc.), and allocation and
// deallocation of objects (and other types of lifetime-related events).

// This boolean is obsolete and unused
BOOL NSKeepAllocationStatistics = NO;

// Object allocation event types
//#define NSObjectAutoreleasedEvent		3
//#define NSObjectExtraRefIncrementedEvent	4
//#define NSObjectExtraRefDecrementedEvent	5
//#define NSObjectInternalRefIncrementedEvent	6
//#define NSObjectInternalRefDecrementedEvent	7


void NSRecordAllocationEvent(int eventType, id object) { }
// Notes an object or zone allocation event and various other
// statistics, such as the time and current thread.
// The behavior is undefined (and likely catastrophic) if
// the correct arguments for 'eventType' are not provided.
//
// The parameter prototypes for each event type are shown below.
//   NSRecordAllocationEvent(NSObjectAutoreleasedEvent, curObj)
//   NSRecordAllocationEvent(NSObjectExtraRefIncrementedEvent, curObj)
//   NSRecordAllocationEvent(NSObjectExtraRefDecrementedEvent, curObj)
//   NSRecordAllocationEvent(NSObjectInternalRefIncrementedEvent, curObj)
//   NSRecordAllocationEvent(NSObjectInternalRefDecrementedEvent, curObj)
//
// Only the Foundation should have reason to use many of these.
// The only common use of this function should be with these two events:
//	NSObjectInternalRefIncrementedEvent
//	NSObjectInternalRefDecrementedEvent
// when a class overrides -retain and -release to do its own
// reference counting.

