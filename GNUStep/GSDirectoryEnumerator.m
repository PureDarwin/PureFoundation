//
//  GSDirectoryEnumerator.m
//  PureFoundation
//
//  Created by Stuart Crook on 06/02/2009.
//  Copyright 2009 Just About Managing ltd. All rights reserved.
//

#import "GSDirectoryEnumerator.h"

/*
 *	This class originally appeared as NSDirectoryEnumerator as part of GNUStep in
 *	the file NSFileManager.m.
 *
 *	The original copyright notice is reproduced here:
 */

	/**
	 NSFileManager.m
 
	 Copyright (C) 1997-2002 Free Software Foundation, Inc.
 
	 Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>
	 Author: Ovidiu Predescu <ovidiu@net-community.com>
	 Date: Feb 1997
	 Updates and fixes: Richard Frith-Macdonald
 
	 Author: Nicola Pero <n.pero@mi.flashnet.it>
	 Date: Apr 2001
	 Rewritten NSDirectoryEnumerator
 
	 Author: Richard Frith-Macdonald <rfm@gnu.org>
	 Date: Sep 2002
	 Rewritten attribute handling code
 
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
 
	 <title>NSFileManager class reference</title>
	 $Date: 2008-12-19 09:06:14 +0000 (Fri, 19 Dec 2008) $ $Revision: 27341 $
	 */

#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>

/* A directory to enumerate.  We keep a stack of the directories we
 still have to enumerate.  We start by putting the top-level
 directory into the stack, then we start reading files from it
 (using readdir).  If we find a file which is actually a directory,
 and if we have to recurse into it, we create a new
 GSEnumeratedDirectory struct for the subdirectory, open its DIR
 *pointer for reading, and put it on top of the stack, so next time
 -nextObject is called, it will read from that directory instead of
 the top level one.  Once all the subdirectory is read, it is
 removed from the stack, so the top of the stack if the top
 directory again, and enumeration continues in there.  */
typedef	struct	_GSEnumeratedDirectory {
	NSString *path;
	DIR *pointer; // sjc: was DIR was _DIR
} GSEnumeratedDirectory;


static inline void gsedRelease(GSEnumeratedDirectory X)
{
	[X.path release]; //DESTROY(X.path);
	closedir(X.pointer); // sjc: was _CLOSEDIR
}

#define GSI_ARRAY_TYPES	0
#define GSI_ARRAY_TYPE	GSEnumeratedDirectory
#define GSI_ARRAY_RELEASE(A, X)   gsedRelease(X.ext)
#define GSI_ARRAY_RETAIN(A, X)

#include "GSIArray.h"


/**
 *  <p>This is a subclass of <code>NSEnumerator</code> which provides a full
 *  listing of all the files beneath a directory and its subdirectories.
 *  Instances can be obtained through [NSFileManager-enumeratorAtPath:],
 *  or through an initializer in this class.  (For compatibility with OS X,
 *  use the <code>NSFileManager</code> method.)</p>
 *
 *  <p>This implementation is optimized and performance should be comparable
 *  to the speed of standard Unix tools for large directories.</p>
 */
@implementation GSDirectoryEnumerator // sjc: was NSDirectoryEnumerator
/*
 * The Objective-C interface hides a traditional C implementation.
 * This was the only way I could get near the speed of standard unix
 * tools for big directories.
 */

+ (void) initialize
{
	if (self == [NSDirectoryEnumerator class])
    {
    }
}

// Initializing

/**
 *  Initialize instance to enumerate contents at path, which should be a
 *  directory and can be specified in relative or absolute, and may include
 *  Unix conventions like '<code>~</code>' for user home directory, which will
 *  be appropriately converted on Windoze systems.  The justContents flag, if
 *  set, is equivalent to recurseIntoSubdirectories = NO and followSymlinks =
 *  NO, but the implementation will be made more efficient.
 */
- (id) initWithDirectoryPath: (NSString*)path
   recurseIntoSubdirectories: (BOOL)recurse
			  followSymlinks: (BOOL)follow
				justContents: (BOOL)justContents 
						 for: (NSFileManager*)mgr
{
	//TODO: the justContents flag is currently basically useless and should be
	//      removed
	DIR		*dir_pointer; // sjc: was _DIR
	const char	*localPath;
	
	self = [super init];
	
	_mgr = [mgr retain]; // sjc: was RETAIN(mgr);
	_stack = NSZoneMalloc([self zone], sizeof(GSIArray_t));
	GSIArrayInitWithZoneAndCapacity(_stack, [self zone], 64);
	
	_flags.isRecursive = recurse;
	_flags.isFollowing = follow;
	_flags.justContents = justContents;
	
	_topPath = [[NSString alloc] initWithString: path];
	
	localPath = [_mgr fileSystemRepresentationWithPath: path];
	dir_pointer = opendir(localPath); // was _OPENDIR
	if (dir_pointer)
    {
		GSIArrayItem item;
		
		item.ext.path = @"";
		item.ext.pointer = dir_pointer;
		
		GSIArrayAddItem(_stack, item);
    }
	else
    {
		NSLog(@"Failed to recurse into directory '%@' - %@", path,
			  [NSError _last]);
    }
	return self;
}

- (void) dealloc
{
	GSIArrayEmpty(_stack);
	NSZoneFree([self zone], _stack);
	[_topPath release]; //DESTROY(_topPath);
	[_currentFilePath release]; //DESTROY(_currentFilePath);
	[_mgr release]; //DESTROY(_mgr);
	[super dealloc];
}

/**
 * Returns a dictionary containing the attributes of the directory
 * at which enumeration started. <br />
 * The contents of this dictionary are as produced by
 * [NSFileManager-fileAttributesAtPath:traverseLink:]
 */
- (NSDictionary*) directoryAttributes
{
	return [_mgr fileAttributesAtPath: _topPath
						 traverseLink: _flags.isFollowing];
}

/**
 * Returns a dictionary containing the attributes of the file
 * currently being enumerated. <br />
 * The contents of this dictionary are as produced by
 * [NSFileManager-fileAttributesAtPath:traverseLink:]
 */
- (NSDictionary*) fileAttributes
{
	return [_mgr fileAttributesAtPath: _currentFilePath
						 traverseLink: _flags.isFollowing];
}

/**
 * Informs the receiver that any descendents of the current directory
 * should be skipped rather than enumerated.  Use this to avoid enumerating
 * the contents of directories you are not interested in.
 */
- (void) skipDescendents
{
	if (GSIArrayCount(_stack) > 0)
    {
		GSIArrayRemoveLastItem(_stack);
		if (_currentFilePath != 0)
		{
			[_currentFilePath release]; //DESTROY(_currentFilePath);
		}
    }
}

/*
 * finds the next file according to the top enumerator
 * - if there is a next file it is put in currentFile
 * - if the current file is a directory and if isRecursive calls
 * recurseIntoDirectory: currentFile
 * - if the current file is a symlink to a directory and if isRecursive
 * and isFollowing calls recurseIntoDirectory: currentFile
 * - if at end of current directory pops stack and attempts to
 * find the next entry in the parent
 * - sets currentFile to nil if there are no more files to enumerate
 */
- (id) nextObject
{
	NSString *returnFileName = 0;
	
	if (_currentFilePath != 0)
    {
		[_currentFilePath release]; //DESTROY(_currentFilePath);
    }
	
	while (GSIArrayCount(_stack) > 0)
    {
		GSEnumeratedDirectory dir = GSIArrayLastItem(_stack).ext;
		struct dirent	*dirbuf; // sjc: was _DIRENT
		struct stat	statbuf; // sjc: was _STATB
		
		dirbuf = readdir(dir.pointer); // sjc: was _READDIR
		
		if (dirbuf)
		{
//#if defined(__MINGW32__)
//			/* Skip "." and ".." directory entries */
//			if (wcscmp(dirbuf->d_name, L".") == 0
//				|| wcscmp(dirbuf->d_name, L"..") == 0)
//			{
//				continue;
//			}
//			/* Name of file to return  */
//			returnFileName = [_mgr
//							  stringWithFileSystemRepresentation: dirbuf->d_name
//							  length: wcslen(dirbuf->d_name)];
//#else
			/* Skip "." and ".." directory entries */
			if (strcmp(dirbuf->d_name, ".") == 0
				|| strcmp(dirbuf->d_name, "..") == 0)
			{
				continue;
			}
			/* Name of file to return  */
			returnFileName = [_mgr
							  stringWithFileSystemRepresentation: dirbuf->d_name
							  length: strlen(dirbuf->d_name)];
//#endif
			returnFileName = [dir.path stringByAppendingPathComponent:
							  returnFileName];
			[returnFileName retain]; //RETAIN(returnFileName);
			
			/* TODO - can this one can be removed ? */
			if (!_flags.justContents)
				_currentFilePath = [[_topPath stringByAppendingPathComponent: // was RETAIN(
										   returnFileName] retain];
			
			if (_flags.isRecursive == YES) // sjc: what ????
			{
				// Do not follow links
//#ifdef S_IFLNK
//#ifdef __MINGW32__
//#warning "lstat does not support unichars"
//#else
				if (!_flags.isFollowing)
				{
					if (lstat([_mgr fileSystemRepresentationWithPath:
							   _currentFilePath], &statbuf) != 0)
					{
						break;
					}
					// If link then return it as link
					if (S_IFLNK == (S_IFMT & statbuf.st_mode))
					{
						break;
					}
				}
				else
//#endif
//#endif
				{
					if (stat([_mgr fileSystemRepresentationWithPath: // sjc: was _STAT
							   _currentFilePath], &statbuf) != 0)
					{
						break;
					}
				}
				if (S_IFDIR == (S_IFMT & statbuf.st_mode))
				{
					DIR*  dir_pointer;
					
					dir_pointer
					= opendir([_mgr fileSystemRepresentationWithPath: // sjc: was _OPENDIR
								_currentFilePath]);
					if (dir_pointer)
					{
						GSIArrayItem item;
						
						item.ext.path = [returnFileName retain];
						item.ext.pointer = dir_pointer;
						
						GSIArrayAddItem(_stack, item);
					}
					else
					{
						NSLog(@"Failed to recurse into directory '%@' - %@",
							  _currentFilePath, [NSError _last]);
					}
				}
			}
			break;	// Got a file name - break out of loop
		}
		else
		{
			GSIArrayRemoveLastItem(_stack);
			if (_currentFilePath != 0)
			{
				[_currentFilePath release]; //DESTROY(_currentFilePath);
			}
		}
    }
	return [returnFileName autorelease];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	
}

@end /* NSDirectoryEnumerator */




