/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSMethodSignature.m
 *
 *	NSMethodSignature
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSMethodSignature.h"
#import <objc/objc.h>
#import "PFObjCTypeTools.h"

/*
 *	Encoding-manipulating functions declared in objc-private.h, which the obj-c 
 *	runtime doesn't expose. We'll try using our own versions, but keep these here
 *	in case we ever need to go back.
 */
//extern unsigned int encoding_getNumberOfArguments(const char *typedesc);
//extern unsigned int encoding_getSizeOfArguments(const char *typedesc);
//extern char * encoding_copyReturnType(const char *t);
//extern char *encoding_copyArgumentType(const char *t, unsigned int index);

/*
 *	Provides information about a particular method signature to NSInvocation
 */

/*
 *	ivars:	void *_private;
 *			void *_reserved[6];
 */
@implementation NSMethodSignature

+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types
{
	PF_HELLO("")

	if( (types == NULL) || (*types == '\0') ) return nil;
	
	//printf("method description: %s\n", types);
	NSLog(@"Creating method signature for: %s", types);
	
	NSMethodSignature *new = [NSMethodSignature alloc];
	
	size_t len = strlen(types);
	new->_private = malloc(len);
	strcpy(new->_private, types);
	
	PF_RETURN_TEMP(new)
}

- (NSUInteger)numberOfArguments
{
	PF_HELLO("")
	//return pf_encoding_getNumberOfArguments(self->_private);
	// do this using our basic functions
	NSUInteger count = 0;
	const char *type = pfenc_process(self->_private, NULL, NULL);
	while( *type != '\0' )
	{
		type = pfenc_process(type, NULL, NULL);
		count++;
	}
	return count;
}

- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx
{
	PF_HELLO("")
	//if( idx > pf_encoding_getNumberOfArguments(self->_private) )
	//	[NSException raise: NSInvalidArgumentException format: nil];
	//return pf_encoding_copyArgumentType(self->_private, idx);
	// again, we should copy the returned value
	
	NSUInteger count = 0;
	const char *type = pfenc_process(self->_private, NULL, NULL); // skip return type

	while( *type != '\0' )
	{
		if( count == idx ) return pfenc_copy(type);
		type = pfenc_process(type, NULL, NULL);
		count++;
	}
	
	// haven't found argument idx, so that's an error
	[NSException raise: NSInvalidArgumentException format: nil];
	return NULL; // stupid compiler
}


- (NSUInteger)frameLength
{
	PF_HELLO("")
	//return pf_encoding_getSizeOfArguments(self->_private);
	NSUInteger length;
	pfenc_process(self->_private, NULL, &length);
	return length;
}

// I'm not sure if this is the way to do it, but...
- (BOOL)isOneway
{
	PF_HELLO("")
	const char *type = self->_private;
	return (*type == 'V');
}


- (const char *)methodReturnType
{
	PF_HELLO("")
	//return pf_encoding_copyReturnType(self->_private);
	// still, we should probably copy this...
	return pfenc_copy(self->_private);
}

- (NSUInteger)methodReturnLength
{
	PF_HELLO("")
	NSUInteger length;
	pfenc_size_align(self->_private, &length, NULL);
	return length;
}

- (const char *)_typeString
{
	return _private;
}

@end

