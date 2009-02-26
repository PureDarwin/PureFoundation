//
//  GSDirectoryEnumerator.h
//  PureFoundation
//
//  Created by Stuart Crook on 06/02/2009.
//  Copyright 2009 Just About Managing ltd. All rights reserved.
//

/*
 *	This class declaration originally appeared as NSDirectoryEnumerator as part
 *	of GNUStep, in the file NSFileManager.h.
 *
 *	The original copyright notice is reporduced below:
 */

	/**
	 NSFileManager.h
 
	 Copyright (C) 1997,1999-2005 Free Software Foundation, Inc.
 
	 Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>
	 Author: Ovidiu Predescu <ovidiu@net-community.com>
	 Date: Feb 1997
 
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
	 */

#import <Foundation/Foundation.h>

@interface GSDirectoryEnumerator : NSDirectoryEnumerator
{
@private
	void *_stack; /* GSIArray */
	NSString *_topPath;
	NSString *_currentFilePath;
	NSFileManager *_mgr;
	struct 
	{
		BOOL isRecursive: 1;
		BOOL isFollowing: 1;
		BOOL justContents: 1;
	} _flags;
}
- (NSDictionary*) directoryAttributes;
- (NSDictionary*) fileAttributes;
- (void) skipDescendents;

- (id) initWithDirectoryPath: (NSString*)path recurseIntoSubdirectories: (BOOL)recurse followSymlinks: (BOOL)follow justContents: (BOOL)justContents for: (NSFileManager*)mgr;

// for fast-enumeration support
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end /* NSDirectoryEnumerator */
