/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSPathUtilities.m
 *
 *	Path utility functions
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSPathUtilities.h"

/*
 *	"Creates a list of directory search paths." "Creates a list of path strings for the specified 
 *	directories in the specified domains. The list is in the order in which you should search the 
 *	directories. If expandTilde is YES, tildes are expanded as described in stringByExpandingTildeInPath."
 *
 *	This function is exported by CFLite from CFPriv.h
 */
extern CFArrayRef CFCopySearchPathForDirectoriesInDomains(int directory, int domainMask, Boolean expandTilde);

NSArray *NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde)
{
	PF_HELLO("")
	return (NSArray *)CFCopySearchPathForDirectoriesInDomains( directory, domainMask, expandTilde );
}


/*
 *	Where noted, the code in this file is based on that of GNUStep. The original source
 *	code file -- NSPathUtilities.m -- began with the following notice:
 */

/* Implementation of filesystem & path-related functions for GNUstep
 Copyright (C) 1996-2004 Free Software Foundation, Inc.
 
 Written by:  Andrew Kachites McCallum <address@hidden>
 Created: May 1996
 Rewrite by:  Sheldon Gill
 Date:    Jan 2004
 Rewrites by:  Richard Frith-Macdonald
 Date:    2004-2005
 
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
 
 <title>NSPathUtilities function reference</title>
 $Date: 2008-12-19 11:54:24 +0000 (Fri, 19 Dec 2008) $ $Revision: 27343 $
 */

#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

//@implementation NSString (NSPathUtilities)
//@end


/*
 *	Functions
 */

/*
 *	"Returns the logon name of the current user."
 *
 *	This function is based on the function of the same name from GNUStep (see original
 *	lisence above).
 */

	/**
	 * Return the caller's login name as an NSString object.<br/ >
	 * Under unix-like systems, the name associated with the current
	 * effective user ID is used.<br/ >
	 * Under ms-windows, the 'LOGNAME' environment is used, or if that fails, the
	 * GetUserName() call is used to find the user name.<br />
	 * Raises an exception on failure.
	 */

NSString *NSUserName(void)
{
	PF_HELLO("")
	
	int uid = geteuid();
	struct passwd *pwent = getpwuid(uid);

	if( (pwent == NULL) || (pwent->pw_name == NULL) )
		[NSException raise: NSInternalInconsistencyException format: @"Unable to determine current user name"];
	
	return [NSString stringWithCString: pwent->pw_name encoding: NSASCIIStringEncoding];
}


/*
 *	"Returns a string containing the full name of the current user."
 *
 *	Also based on GNUStep.
 */
NSString *NSFullUserName(void) 
{ 
	PF_HELLO("")
	
	int uid = geteuid();
	struct passwd *pwent = getpwuid(uid);
	
	if( (pwent == NULL) || (pwent->pw_gecos == NULL) )
		return @"";

	return [NSString stringWithCString: pwent->pw_gecos encoding: NSUTF8StringEncoding];
}

/*
 *	"Returns the path to the current user’s home directory."
 */
NSString *NSHomeDirectory(void) 
{ 
	PF_HELLO("")

	char buffer[256];
	
	if( confstr(_CS_DARWIN_USER_DIR, buffer, 256) <= 0 )
		[NSException raise: NSInternalInconsistencyException format: @"Unable to determine user's home directory"];
	
	//printf("homedir: %s\n", buffer);
	
	return [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding];
}

/*
 *	"Returns the path to a given user’s home directory."
 *
 *	Also based on GNUStep.
 */
NSString *NSHomeDirectoryForUser(NSString *userName) 
{
	PF_HELLO("")
	
	struct passwd *pwent = getpwnam( [userName UTF8String] );
	
	if( (pwent == NULL) || (pwent->pw_dir == NULL) )
		return @"";
	
	return [NSString stringWithCString: pwent->pw_dir encoding: NSUTF8StringEncoding];
}

/*
 *	"Returns the path of the temporary directory for the current user." "The temporary directory 
 *	is determined by confstr(3) passing the _CS_DARWIN_USER_TEMP_DIR flag. The erase rules are 
 *	whatever match that directory."
 */
NSString *NSTemporaryDirectory(void) 
{
	PF_HELLO("")
	
	char buffer[256];
	
	if( confstr(_CS_DARWIN_USER_TEMP_DIR, buffer, 256) <= 0 )
		[NSException raise: NSInternalInconsistencyException format: @"Unable to determine temp directory"];
	
	return [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding];
}

/*
 *	"Returns the root directory of the user’s system."
 */
NSString *NSOpenStepRootDirectory(void) 
{
	PF_HELLO("")
	return @"/";
}


