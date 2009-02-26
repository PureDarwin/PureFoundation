/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSObjCRuntime.m
 *
 *	Various low-level functions
 *
 *	Created by Stuart Crook on 13/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSObjCRuntime.h"
#import "Foundation/NSString.h"
#import <objc/runtime.h>
//#import "GSNextRuntime.h"
#import "PFObjCTypeTools.h"

#import "../CF-476.15/CFLogUtilities.h"

/*
 *	Set this to the version of the proper Foundation we're trying to be
 */
double NSFoundationVersionNumber = NSFoundationVersionNumber10_4_11;

/*
 *	NSString-to/from-obj-C runtime functions
 */
NSString *NSStringFromSelector(SEL aSelector)
{
	PF_HELLO("")
	return [NSString stringWithUTF8String: sel_getName(aSelector)];
}

SEL NSSelectorFromString(NSString *aSelectorName)
{
	PF_HELLO("")
	return sel_getUid([aSelectorName UTF8String]);
}

NSString *NSStringFromClass(Class aClass)
{
	PF_HELLO("")
	return [NSString stringWithUTF8String: class_getName(aClass)];
}

Class NSClassFromString(NSString *aClassName)
{
	PF_HELLO("")
	return objc_getClass([aClassName UTF8String]);
}

NSString *NSStringFromProtocol(Protocol *proto)
{
	PF_HELLO("")
	return [NSString stringWithUTF8String: protocol_getName(proto)];
}

Protocol *NSProtocolFromString(NSString *namestr)
{
	PF_HELLO("")
	return objc_getProtocol([namestr UTF8String]);
}

/*
 *	The implementation of NSGetSizeAndAlignment() below is taken from
 *	GNUStep, line #132 of NSObjCRuntime.m
 */

	/** Implementation of ObjC runtime for GNUStep
	 Copyright (C) 1995 Free Software Foundation, Inc.
 
	 Written by:  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
	 Date: Aug 1995
 
	 This file is part of the GNUstep Base Library.
 
	 This library is free software; you can redistribute it and/or
	 modify it under the terms of the GNU Lesser General Public
	 License as published by the Free Software Foundation; either
	 version 2 of the License, or (at your option) any later version.
 
	 This library is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 Library General Public License for more details.
 
	 You should have received a copy of the GNU Lesser General Public
	 License along with this library; if not, write to the Free
	 Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
	 Boston, MA 02111 USA.
 
	 <title>NSObjCRuntime class reference</title>
	 $Date: 2008-06-12 11:44:00 +0100 (Thu, 12 Jun 2008) $ $Revision: 26630 $
	 */

/**
 * When provided with a C string containing encoded type information,
 * this method extracts size and alignment information for the specified
 * type into the buffers pointed to by sizep and alignp.<br />
 * If either sizep or alignp is a nil pointer, the corresponding data is
 * not extracted.<br />
 * The function returns a pointer to the type information C string.
 */
const char *NSGetSizeAndAlignment(const char *typePtr, NSUInteger *sizep, NSUInteger *alignp)
{

	/** TODO:
	 *		Well, it turns out that NSGetSizeAndAlignment() should really live
	 *	in CoreFoundation -- that's where the linker looks for it. So we should
	 *	move it (and the supprting function calls) when we do the next big CFLite
	 *	patch.
	 */
	
	//NSArgumentInfo	info;
	//typePtr = mframe_next_arg(typePtr, &info, 0);
	//if (sizep)
	//	*sizep = info.size;
	//if (alignp)
	//	*alignp = info.align;
	NSUInteger s, a;

	typePtr = pfenc_size_align(typePtr, &s, &a);
	typePtr = pfenc_offset(typePtr, NULL);
	
	if( sizep != NULL ) *sizep = s;
	if( alignp != NULL ) *alignp = a;
	
	return typePtr;
}
// End GNUStep stuff

/*
 *	NSLog simply parses the arguments and then calls NSLogv...
 */
void NSLog(NSString *format, ...) //__attribute__((format(__NSString__, 1, 2)));
{
	PF_HELLO("")
	
	va_list arguments;
	va_start( arguments, format );
	NSLogv( format, arguments );
	va_end( arguments );
}

/*
 *	...which calls the super-secret CFLog(), which does a rather good job of being NSLog()
 */
void NSLogv(NSString *format, va_list args)
{
	PF_HELLO("")
	//printf("-- calling CFLog --\n");
	NSString *msg = [[NSString alloc] initWithFormat: format arguments: args];
	//printf("msg: 0x%X - ", msg);
	CFLog( kCFLogLevelNotice, (CFStringRef)msg );
	[msg release];
	PF_DEBUG("-- back from CFLog --\n"); //these proved that CFLog, on first calling does																	//	_A LOT_ of retain/releasing
}


