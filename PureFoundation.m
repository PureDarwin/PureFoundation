/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PureFoundation.m
 *
 *	Common functions and variables
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "PureFoundation.h"

// default state of multi-thread flag
BOOL _pf_IsMultiThreaded = YES;

/*
 *	Objective-C message-sending callbacks for use with CF collections
 */
// declarations
CFStringRef _PFDescriptionCallBack(const void *value );
Boolean _PFEqualsCallBack( const void *value1, const void *value2 );
CFHashCode _PFHashCallBack( const void *value );
void _PFReleaseCallBack( CFAllocatorRef allocator, const void *value );
const void *_PFRetainCallBack( CFAllocatorRef allocator, const void *value );

// actual functions
// maybe the description should recieve an extra -retain so that CF's release doesn't cause problems
CFStringRef _PFDescriptionCallBack(const void *value ) { return (CFStringRef)[[(id)value description] retain]; }
Boolean _PFEqualsCallBack( const void *value1, const void *value2 ) { return [(id)value1 isEqual: (id)value2]; }
CFHashCode _PFHashCallBack( const void *value ) { return (CFHashCode)[(id)value hash]; }
const void *_PFRetainCallBack( CFAllocatorRef allocator, const void *value ) 
{
	//printf("collection retain called on 0X%X\n", value); 
	return (const void *)[(id)value retain]; 
}

void _PFReleaseCallBack( CFAllocatorRef allocator, const void *value ) 
{
	//printf("collection release called on 0x%X\n", value); 
	[(id)value release]; 
}

// and the callback structure
CFSetCallBacks _PFCollectionCallBacks = { 0, _PFRetainCallBack, _PFReleaseCallBack, _PFDescriptionCallBack, _PFEqualsCallBack, _PFHashCallBack };

/*
 *	NSRequestConcreteImplementation
 *
 *	Throw an NSInvalidArgumentException and display a message about how sel cannot be sent to an
 *	abstract object of class cls eg. "*** Terminating app due to uncaught exception 
 *	'NSInvalidArgumentException', reason: '*** -init cannot be sent to an abstract object of class 
 *	NSObject: Create a concrete instance!'"
 *	
 *	Used by NSOpenDirectory in the OpenDirectory project.
 */
void NSRequestConcreteImplementation( id anObject, SEL sel, Class cls )
{
	PF_HELLO("")
	[NSException raise: NSInvalidArgumentException format: @"Request a Concrete Implementation"];
}