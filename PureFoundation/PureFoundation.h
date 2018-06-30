/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PureFoundation.h
 *
 *	Common functions and variables
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSObjCRuntime.h>

/*
 *	Has at least 1 thread been spawned? Used to control use of mutexes.
 */
BOOL _pf_IsMultiThreaded;

/*
 *	Objective-C message-sending callbacks for use with CF collections, because otherwise
 *	non-CF-derived objects cause bad things to happen
 */
CFSetCallBacks _PFCollectionCallBacks;

@interface NSMethodSignature (NSMethodSignaturePFPrivateAccess)
-(const char*)_typeString;
@end

/*
 *	NOTES about individual files
 *
 *		* FoundationErrors.h is just error codes
 *		* NSAffineTransform.h -- do we need to implement this?
 *		* NSAppleEventDescriptor.h }
 *		* NSAppleEventManager.h    } do we need to implement these?
 *		* NSAppleScript.h          }
 *
 *		* NSByteOrder.h contains inlined CF wrappers. Nothing more to do there.
 *
 *
 *
 */
/*
 *	This header file (and the accompanying PureFoundation.m) is used to gather together all of the 
 *	esoteric functions and constants defined relied upon by Darwin projects but not declared in Apple's
 *	standard Foundation headers
 */

/*
 *	NSRequestConcreteImplementation
 */
void NSRequestConcreteImplementation( id anObject, SEL sel, Class cls );