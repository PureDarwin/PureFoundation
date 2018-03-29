/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSFileManager.m
 *
 *	NSFileManager and NSDictionary file attribute additions
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSFileManager.h"

#import "NSDictionary.h"
#import "NSString.h"


/*
 *	Constants
 */
NSString * const NSFileType = @"NSFileType";
NSString * const NSFileTypeDirectory = @"NSFileTypeDirectory";
NSString * const NSFileTypeRegular = @"NSFileTypeRegular";
NSString * const NSFileTypeSymbolicLink = @"NSFileTypeSymbolicLink";
NSString * const NSFileTypeSocket = @"NSFileTypeSocket";
NSString * const NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
NSString * const NSFileTypeBlockSpecial = @"NSFileTypeBlockSpecial";
NSString * const NSFileTypeUnknown = @"NSFileTypeUnknown";
NSString * const NSFileSize = @"NSFileSize";
NSString * const NSFileModificationDate = @"NSFileModificationDate";
NSString * const NSFileReferenceCount = @"NSFileReferenceCount";
NSString * const NSFileDeviceIdentifier	= @"NSFileDeviceIdentifier";
NSString * const NSFileOwnerAccountName	= @"NSFileOwnerAccountName";
NSString * const NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
NSString * const NSFilePosixPermissions = @"NSFilePosixPermissions";
NSString * const NSFileSystemNumber = @"NSFileSystemNumber";
NSString * const NSFileSystemFileNumber = @"NSFileSystemFileNumber";
NSString * const NSFileExtensionHidden = @"NSFileExtensionHidden";
NSString * const NSFileHFSCreatorCode = @"NSFileHFSCreatorCode";
NSString * const NSFileHFSTypeCode = @"NSFileHFSTypeCode";
NSString * const NSFileImmutable = @"NSFileImmutable";
NSString * const NSFileAppendOnly = @"NSFileAppendOnly";
NSString * const NSFileCreationDate = @"NSFileCreationDate";
NSString * const NSFileOwnerAccountID = @"NSFileOwnerAccountID";
NSString * const NSFileGroupOwnerAccountID = @"NSFileGroupOwnerAccountID";
NSString * const NSFileBusy = @"NSFileBusy";

NSString * const NSFileSystemSize		= @"NSFileSystemSize";
NSString * const NSFileSystemFreeSize	= @"NSFileSystemFreeSize";
NSString * const NSFileSystemNodes		= @"NSFileSystemNodes";
NSString * const NSFileSystemFreeNodes	= @"NSFileSystemFreeNodes";

/*
 *	Category on NSDictionary to handle particular file attributes, keyed to the
 *	constants listed above.
 *
 *	If speed is a concern then these can be over-ridden in NSCFDictionary to make
 *	the appropriate calls directly into (CFDictionaryRef)self.
 */
@implementation NSDictionary (NSFileAttributes)

- (unsigned long long)fileSize
{
	NSNumber *temp = [self objectForKey: NSFileSize];
	return (temp == nil) ? 0 : [temp longLongValue];
}

- (NSDate *)fileModificationDate
{
	return [self objectForKey: NSFileModificationDate];
}

- (NSString *)fileType
{
	return [self objectForKey: NSFileType];
}

- (NSUInteger)filePosixPermissions
{
	NSNumber *temp = [self objectForKey: NSFilePosixPermissions];
	return (temp == nil) ? 0 : [temp integerValue];
}

- (NSString *)fileOwnerAccountName
{
	return [self objectForKey: NSFileOwnerAccountName];
}

- (NSString *)fileGroupOwnerAccountName
{
	return [self objectForKey: NSFileGroupOwnerAccountName];
}

- (NSInteger)fileSystemNumber
{
	NSNumber *temp = [self objectForKey: NSFileSystemNumber];
	return (temp == nil) ? 0 : [temp integerValue];
}

- (NSUInteger)fileSystemFileNumber
{
	NSNumber *temp = [self objectForKey: NSFileExtensionHidden];
	return (temp == nil) ? 0 : [temp integerValue];
}

- (BOOL)fileExtensionHidden
{
	NSNumber *temp = [self objectForKey: NSFileExtensionHidden];
	return (temp == nil) ? NO : [temp boolValue];
}

- (OSType)fileHFSCreatorCode
{
	NSNumber *temp = [self objectForKey: NSFileHFSCreatorCode];
	return (temp == nil) ? 0 : (OSType)[temp integerValue];
}

- (OSType)fileHFSTypeCode
{
	NSNumber *temp = [self objectForKey: NSFileHFSTypeCode];
	return (temp == nil) ? 0 : (OSType)[temp integerValue];
}

- (BOOL)fileIsImmutable
{
	NSNumber *temp = [self objectForKey: NSFileImmutable];
	return (temp == nil) ? NO : [temp boolValue];
}

- (BOOL)fileIsAppendOnly
{
	NSNumber *temp = [self objectForKey: NSFileAppendOnly];
	return (temp == nil) ? NO : [temp boolValue];
}

- (NSDate *)fileCreationDate
{
	return [self objectForKey: NSFileCreationDate];
}

- (NSNumber *)fileOwnerAccountID
{
	return [self objectForKey: NSFileOwnerAccountID];
}

- (NSNumber *)fileGroupOwnerAccountID
{
	return [self objectForKey: NSFileGroupOwnerAccountID];
}

@end



/*
 *	This implementation is here purely to give us somthing to hang GSDirectoryEnumerator
 *	off of
 */
@implementation NSDirectoryEnumerator
- (NSDictionary *)fileAttributes { return nil; }
- (NSDictionary *)directoryAttributes { return nil; }
- (void)skipDescendents {}
@end



/*
 *	This implementation of NSFileManager is based on GNUStep's, found in NSFileManager.m
 *
 *	Original copyright notice:
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
#include <pwd.h>
#include <grp.h>
#include <sys/stat.h>
#include <utime.h>
#include <fcntl.h>
#include <sys/statvfs.h>

#import "GSDirectoryEnumerator.h"

/*
 *	Changes have been made to remove non-relevant code sections, remove the reliance
 *	on the _lastError ivar, and support OS X 10.5 instances, delegates and delegate
 *	methods.
 *
 *	In the case of the new ...error: methods, where the function appears to be identical, 
 *	the GNUStep original has been renamed and it's original error handling adapted to use
 *	the error parameter, while another function with the old name has been created which
 *	calls the other function and simply discards the error
 *
 *	In the case of the new delegate-using versions of the methods, the GNUStep original has
 *	simply been cut-and-pasted to form the new one.
 */
static NSFileManager *_PFDefaultFileManager = nil;
static CFMutableDictionaryRef _PFFileManagerDelegates = nil;

/*
 *	GNUStep uses a really-neat custom NSDictionary subclass to hold file attributes. We
 *	should do the same. Some day. For now, to avoid the complications of custom enumerators
 *	and fast enumeration support, we will just fill a normal dictionary.
 */
#define PF_ATTR_COUNT 11
const id  _PFAttributeKeys[PF_ATTR_COUNT] = { 
	@"NSFileCreationDate", 
	//@"NSFileExtensionHidden",
	@"NSFileGroupOwnerAccountID",
	@"NSFileGroupOwnerAccountName",
	//@"NSFileHFSCreatorCode",
	//@"NSFileHFSTypeCode",
	//@"NSFileAppendOnly",
	//@"NSFileImmutable",
	@"NSFileModificationDate",
	@"NSFileOwnerAccountID",
	@"NSFileOwnerAccountName",
	@"NSFilePosixPermissions",
	@"NSFileSize",
	@"NSFileSystemFileNumber",
	@"NSFileSystemNumber",
	@"NSFileType"
};

CFDictionaryRef _PFDictionaryFromStat( struct stat statbuf )
{
	id ptr[PF_ATTR_COUNT];
	
	// we'll do these in the order they're listed in the NSDictionary docs
	// file creation date -- on 64-bit, statbuf.st_birthtime gives this without the hack
	ptr[0] = (statbuf.st_ctime < statbuf.st_mtime) ? [NSDate dateWithTimeIntervalSince1970: statbuf.st_ctime] : [NSDate dateWithTimeIntervalSince1970: statbuf.st_mtime];
	// file extension hidden
		// skip, because it's missing in GNUStep
	// file  group owner account id
	ptr[1] = [NSNumber numberWithUnsignedLong: statbuf.st_gid];
	// file group owner account name
	struct group gp;
	struct group *p;
	char buf[BUFSIZ*10];
	
	if (getgrgid_r(statbuf.st_gid, &gp, buf, sizeof(buf), &p) == 0)
		ptr[2] = [NSString stringWithCString: gp.gr_name encoding: NSUTF8StringEncoding];
    else
		ptr[2] = @"Unknown Group";
	
	// HFS creator code
	// HFS type code
		// maybe cocotron will know how to fake these
	// file is appendable
	// file is immutable
		// skip these, too
	// file modification date
	ptr[3] = [NSDate dateWithTimeIntervalSince1970: statbuf.st_mtime];
	// file owner account id
	ptr[4] = [NSNumber numberWithUnsignedLong: statbuf.st_uid];
	// file owner account name
	struct passwd *pw;
	
	//[gnustep_global_lock lock];
	pw = getpwuid(statbuf.st_uid);
	if (pw != 0)
		ptr[5] = [NSString stringWithCString: pw->pw_name encoding: NSUTF8StringEncoding];
    else
		ptr[5] = @"Unknown Owner";
	//[gnustep_global_lock unlock];
	
	// file POSIX permissions
	ptr[6] = [NSNumber numberWithUnsignedLong: (statbuf.st_mode & ~S_IFMT)];
	// file size
	ptr[7] = [NSNumber numberWithUnsignedLongLong: statbuf.st_size];
	// file system file number
	ptr[8] = [NSNumber numberWithUnsignedLong: statbuf.st_ino];
	// file system number
	ptr[9] = [NSNumber numberWithUnsignedLong: statbuf.st_dev];
	// file type
	switch (statbuf.st_mode & S_IFMT)
    {
		case S_IFREG: 
			ptr[10] = NSFileTypeRegular; 
			break;
		case S_IFDIR: 
			ptr[10] = NSFileTypeDirectory;
			break;
		case S_IFCHR:
			ptr[10] = NSFileTypeCharacterSpecial;
			break;
		case S_IFBLK:
			ptr[10] = NSFileTypeBlockSpecial;
			break;
		case S_IFLNK:
			ptr[10] = NSFileTypeSymbolicLink;
			break;
		//case S_IFIFO:
		//	*ptr++ = NSFileTypeFifo;
		//	break;
		case S_IFSOCK:
			ptr[10] = NSFileTypeSocket;
			break;
		default:
			ptr[10] = NSFileTypeUnknown;
    }
	//ptr -= PF_ATTR_COUNT; // rewind
	// note that NULL which means that the keys won't be copied
	return CFDictionaryCreate( kCFAllocatorDefault, (const void **)&_PFAttributeKeys, (const void **)ptr, PF_ATTR_COUNT, NULL, &kCFTypeDictionaryValueCallBacks );
}



@implementation NSFileManager

/**
 * Returns a shared default file manager which may be used throughout an
 * application.
 */
+ (NSFileManager*) defaultManager
{
	if (_PFDefaultFileManager == nil)
    {
		//NS_DURING
		//{
			//[gnustep_global_lock lock];
			if (_PFDefaultFileManager == nil)
			{
				_PFDefaultFileManager = [[self alloc] init];
			}
			//[gnustep_global_lock unlock];
		//}
		//NS_HANDLER
		//{
			// unlock then re-raise the exception
			//[gnustep_global_lock unlock];
			//[localException raise];
		//}
		//NS_ENDHANDLER
    }
	return _PFDefaultFileManager;
}

//+ (void) initialize
//{
//	defaultEncoding = [NSString defaultCStringEncoding];
//}

//- (void) dealloc
//{
//	TEST_RELEASE(_lastError);
//	[super dealloc];
//}

/**
 * Changes the current directory used for all subsequent operations.<br />
 * All non-absolute paths are interpreted relative to this directory.<br />
 * The current directory is set on a per-task basis, so the current
 * directory for other file manager instances will also be changed
 * by this method.
 */
- (BOOL) changeCurrentDirectoryPath: (NSString*)path
{
	//static Class	bundleClass = 0;
	const char *lpath = [self fileSystemRepresentationWithPath: path];
	
	/*
	 * On some systems the only way NSBundle can determine the path to the
	 * executable is by searching for it ... so it needs to know what was
	 * the current directory at launch time ... so we must make sure it is
	 * initialised before we change the current directory.
	 */
	//if (bundleClass == 0)
    //{
	//	bundleClass = [NSBundle class];
    //}
	return (chdir(lpath) == 0) ? YES : NO;
}


/**
 * Change the attributes of the file at path to those specified.<br />
 * Returns YES if all requested changes were made (or if the dictionary
 * was nil or empty, so no changes were requested), NO otherwise.<br />
 * On failure, some of the requested changes may have taken place.<br />
 */
- (BOOL) changeFileAttributes: (NSDictionary*)attributes atPath: (NSString*)path
{
	return [self setAttributes: attributes ofItemAtPath: path error: NULL];
}

/* "setAttributes:ofItemAtPath:error: returns YES when the attributes specified in the 'attributes' dictionary are set successfully on the item specified by 'path'. If this method returns NO, a presentable NSError will be provided by-reference in the 'error' parameter. If no error is required, you may pass 'nil' for the error.
 
	"This method replaces changeFileAttributes:atPath:."
 */
- (BOOL)setAttributes:(NSDictionary *)attributes ofItemAtPath:(NSString *)path error:(NSError **)error
{
	const char	*lpath = 0;
	NSNumber *num_r; // for return from fileOwnerAccountID
	unsigned long	num;
	NSString	*str;
	NSDate	*date;
	BOOL		allOk = YES;
	
	if (attributes == nil)
    {
		return YES;
    }
	lpath = [self fileSystemRepresentationWithPath: path]; // was defaultManager
	
//#ifndef __MINGW32__
	num_r = [attributes fileOwnerAccountID]; // _sjc_: return NSNumber
	if (num_r != nil) //NSNotFound)
    {
		num = [num_r integerValue];
		if (chown(lpath, num, -1) != 0)
		{
			allOk = NO;
			if( error != NULL )
				*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];
			//str = [NSString stringWithFormat:
			//	   @"Unable to change NSFileOwnerAccountID to '%u' - %@",
			//	   num, [NSError _last]];
			//ASSIGN(_lastError, str); // _sjc_
		}
    }
	else
    {
		if ((str = [attributes fileOwnerAccountName]) != nil)
		{
			BOOL	ok = NO;
//#ifdef HAVE_PWD_H
//#if     defined(HAVE_GETPWNAM_R)
			struct passwd pw;
			struct passwd *p;
			char buf[BUFSIZ*10];
			
			if (getpwnam_r([str cStringUsingEncoding: [NSString defaultCStringEncoding]],
						   &pw, buf, sizeof(buf), &p) == 0)
			{
				ok = (chown(lpath, pw.pw_uid, -1) == 0);
				chown(lpath, -1, pw.pw_gid);
			}
//#else
//#if     defined(HAVE_GETPWNAM)
//			struct passwd *pw;
//			
//			[gnustep_global_lock lock];
//			pw = getpwnam([str cStringUsingEncoding: defaultEncoding]);
//			if (pw != 0)
//			{
//				ok = (chown(lpath, pw->pw_uid, -1) == 0);
//				chown(lpath, -1, pw->pw_gid);
//			}
//			[gnustep_global_lock unlock];
//#endif
//#endif
//#endif
			if (ok == NO)
			{
				allOk = NO;
				// this probably isn't correct
				if( error != NULL )
					*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];

				//str = [NSString stringWithFormat:
				//	   @"Unable to change NSFileOwnerAccountName to '%@' - %@",
				//	   str, [NSError _last]];
				//ASSIGN(_lastError, str);
			}
		}
    }
	
	num_r = [attributes fileGroupOwnerAccountID];
	if (num_r != nil) //NSNotFound)
    {
		num = [num_r integerValue];
		if (chown(lpath, -1, num) != 0)
		{
			allOk = NO;
			if( error != NULL )
				*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];

			//str = [NSString stringWithFormat:
			//	   @"Unable to change NSFileGroupOwnerAccountID to '%u' - %@",
			//	   num, [NSError _last]];
			//ASSIGN(_lastError, str);
		}
    }
	else if ((str = [attributes fileGroupOwnerAccountName]) != nil)
    {
		BOOL	ok = NO;
//#ifdef HAVE_GRP_H
//#ifdef HAVE_GETGRNAM_R
		struct group gp;
		struct group *p;
		char buf[BUFSIZ*10];
		
		if (getgrnam_r([str cStringUsingEncoding: [NSString defaultCStringEncoding]], &gp,
					   buf, sizeof(buf), &p) == 0)
        {
			if (chown(lpath, -1, gp.gr_gid) == 0)
				ok = YES;
        }
//#else
//#ifdef HAVE_GETGRNAM
//		struct group *gp;
//		
//		[gnustep_global_lock lock];
//		gp = getgrnam([str cStringUsingEncoding: defaultEncoding]);
//		if (gp)
//		{
//			if (chown(lpath, -1, gp->gr_gid) == 0)
//				ok = YES;
//		}
//		[gnustep_global_lock unlock];
//#endif
//#endif
//#endif
		if (ok == NO)
		{
			allOk = NO;
			// again, probably not the correct error
			if( error != NULL )
				*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];

			//str = [NSString stringWithFormat:
			//	   @"Unable to change NSFileGroupOwnerAccountName to '%@' - %@",
			//	   str, [NSError _last]];
			//ASSIGN(_lastError, str);
		}
    }
//#endif	/* __MINGW32__ */
	
	num = [attributes filePosixPermissions];
	if (num != 0) //NSNotFound)
    {
		if (chmod(lpath, num) != 0) // _sjc_: was _CHMOD
		{
			allOk = NO;
			if( error != NULL )
				*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];

			//str = [NSString stringWithFormat:
			//	   @"Unable to change NSFilePosixPermissions to '%o' - %@",
			//	   num, [NSError _last]];
			//ASSIGN(_lastError, str);
		}
    }
	
	date = [attributes fileModificationDate];
	if (date != nil)
    {
		BOOL		ok = NO;
		struct stat	sb; // was _STATB
		
//#if  defined(__WIN32__) || defined(_POSIX_VERSION)
		struct utimbuf ub; // was _UTIMB
//#else
//		time_t ub[2];
//#endif

		if (stat(lpath, &sb) != 0) // was _STAT
		{
			ok = NO;
		}
//#if  defined(__WIN32__)
//		else if (sb.st_mode & _S_IFDIR)
//		{
//			ok = YES;	// Directories don't have modification times.
//		}
//#endif
		else
		{
//#if  defined(__WIN32__) || defined(_POSIX_VERSION)
			ub.actime = sb.st_atime;
			ub.modtime = [date timeIntervalSince1970];
			ok = (utime(lpath, &ub) == 0); // was _UTIME
//#else
//			ub[0] = sb.st_atime;
//			ub[1] = [date timeIntervalSince1970];
//			ok = (_UTIME(lpath, ub) == 0);
//#endif
		}
		if (ok == NO)
		{
			allOk = NO;
			// need a different error message here
			if( error != NULL )
				*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];

			//str = [NSString stringWithFormat:
			//	   @"Unable to change NSFileModificationDate to '%@' - %@",
			//	   date, [NSError _last]];
			//ASSIGN(_lastError, str);
		}
    }
	
	return allOk;
}

/**
 * Returns an array of path components suitably modified for display
 * to the end user.  This modification may render the returned strings
 * unusable for path manipulation, so you should work with two arrays ...
 * one returned by this method (for display to the user), and a
 * parallel one returned by [NSString-pathComponents] (for path
 * manipulation).
 */
- (NSArray*) componentsToDisplayForPath: (NSString*)path
{
	return [path pathComponents];
}

/**
 * Reads the file at path an returns its contents as an NSData object.<br />
 * If an error occurs or if path specifies a directory etc then nil is
 * returned.
 */
- (NSData*) contentsAtPath: (NSString*)path
{
	return [NSData dataWithContentsOfFile: path];
}

/**
 * Returns YES if the contents of the file or directory at path1 are the same
 * as those at path2.<br />
 * If path1 and path2 are files, this is a simple comparison.  If they are
 * directories, the contents of the files in those subdirectories are
 * compared recursively.<br />
 * Symbolic links are not followed.<br />
 * A comparison checks first file identity, then size, then content.
 */
- (BOOL) contentsEqualAtPath: (NSString*)path1 andPath: (NSString*)path2
{
	NSDictionary	*d1;
	NSDictionary	*d2;
	NSString	*t;
	
	if ([path1 isEqual: path2])
		return YES;
	d1 = [self fileAttributesAtPath: path1 traverseLink: NO];
	d2 = [self fileAttributesAtPath: path2 traverseLink: NO];
	t = [d1 fileType];
	if ([t isEqual: [d2 fileType]] == NO)
    {
		return NO;
    }
	if ([t isEqual: NSFileTypeRegular])
    {
		if ([d1 fileSize] == [d2 fileSize])
		{
			NSData	*c1 = [NSData dataWithContentsOfFile: path1];
			NSData	*c2 = [NSData dataWithContentsOfFile: path2];
			
			if ([c1 isEqual: c2])
			{
				return YES;
			}
		}
		return NO;
    }
	else if ([t isEqual: NSFileTypeDirectory])
    {
		NSArray	*a1 = [self directoryContentsAtPath: path1];
		NSArray	*a2 = [self directoryContentsAtPath: path2];
		unsigned	index, count = [a1 count];
		BOOL	ok = YES;
		
		if ([a1 isEqual: a2] == NO)
		{
			return NO;
		}
		for (index = 0; ok == YES && index < count; index++)
		{
			NSString	*n = [a1 objectAtIndex: index];
			NSString	*p1;
			NSString	*p2;
			//CREATE_AUTORELEASE_POOL(pool);
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			p1 = [path1 stringByAppendingPathComponent: n];
			p2 = [path2 stringByAppendingPathComponent: n];
			d1 = [self fileAttributesAtPath: p1 traverseLink: NO];
			d2 = [self fileAttributesAtPath: p2 traverseLink: NO];
			t = [d1 fileType];
			if ([t isEqual: [d2 fileType]] == NO)
			{
				ok = NO;
			}
			else if ([t isEqual: NSFileTypeDirectory])
			{
				ok = [self contentsEqualAtPath: p1 andPath: p2];
			}
			//RELEASE(pool);
			[pool drain]; // which also releases
		}
		return ok;
    }
	else
    {
		return YES;
    }
}

/**
 * Creates a new directory and all intermediate directories
 * if flag is YES, creates only the last directory in the path
 * if flag is NO.  The directory is created with the attributes
 * specified in attributes and any error is returned in error.<br />
 * returns YES on success, NO on failure.
 */
- (BOOL) createDirectoryAtPath: (NSString *)path
   withIntermediateDirectories: (BOOL)flag
					attributes: (NSDictionary *)attributes
						 error: (NSError **) error
{
	BOOL result = NO;
	
	if (flag == YES)
    {
		NSEnumerator *paths = [[path pathComponents] objectEnumerator];
		NSString *path = nil;
		NSString *dir = [NSString string];
		
		while ((path = (NSString *)[paths nextObject]) != nil)
		{
			dir = [dir stringByAppendingPathComponent: path];
			result = [self createDirectoryAtPath: dir
									  attributes: attributes];
		}
    }
	else
    {
		result = [self createDirectoryAtPath: [path lastPathComponent]
								  attributes: attributes];
    }  
	
	if (error != NULL)
    {
		*error = [NSError _last];
    }
	return result;
}

/**
 * Creates a new directory, and sets its attributes as specified.<br />
 * Creates other directories in the path as necessary.<br />
 * Returns YES on success, NO on failure.
 */
- (BOOL) createDirectoryAtPath: (NSString*)path
					attributes: (NSDictionary*)attributes
{
//#if defined(__MINGW32__)
//	NSEnumerator	*paths = [[path pathComponents] objectEnumerator];
//	NSString	*subPath;
//	NSString	*completePath = nil;
//#else
	const char	*lpath;
	char		dirpath[PATH_MAX+1];
	struct stat	statbuf; // was _STATB
	int		len, cur;
	NSDictionary	*needChown = nil;
//#endif
	
	/* This is consistent with MacOSX - just return NO for an invalid path. */
	if ([path length] == 0)
		return NO;
	
//#if defined(__MINGW32__)
//	while ((subPath = [paths nextObject]))
//    {
//		BOOL isDir = NO;
//		
//		if (completePath == nil)
//			completePath = subPath;
//		else
//			completePath = [completePath stringByAppendingPathComponent: subPath];
//		
//		if ([self fileExistsAtPath: completePath isDirectory: &isDir])
//		{
//			if (!isDir)
//				NSLog(@"WARNING: during creation of directory %@:"
//					  @" sub path %@ exists, but is not a directory !",
//					  path, completePath);
//        }
//		else
//		{
//			const _CHAR *lpath;
//			
//			lpath = [self fileSystemRepresentationWithPath: completePath];
//			if (CreateDirectoryW(lpath, 0) == FALSE)
//			{
//				return NO;
//			}
//        }
//    }
//	
//#else
	
	/*
	 * If there is no file owner specified, and we are running setuid to
	 * root, then we assume we need to change ownership to correct user.
	 */
	if (attributes == nil || ([attributes fileOwnerAccountID] == nil // _sjc_: not NSNotFound
							  && [attributes fileOwnerAccountName] == nil))
    {
		if (geteuid() == 0 && [@"root" isEqualToString: NSUserName()] == NO)
		{
			needChown = [NSDictionary dictionaryWithObjectsAndKeys:
						 NSFileOwnerAccountName, NSUserName(), nil];
		}
    }
	lpath = [self fileSystemRepresentationWithPath: path];
	len = strlen(lpath);
	if (len > PATH_MAX) // name too long
    {
		//ASSIGN(_lastError, @"Could not create directory - name too long");
		return NO;
    }
	
	if (strcmp(lpath, "/") == 0 || len == 0) // cannot use "/" or ""
    {
		//ASSIGN(_lastError, @"Could not create directory - no name given");
		return NO;
    }
	
	strcpy(dirpath, lpath);
	dirpath[len] = '\0';
	if (dirpath[len-1] == '/')
		dirpath[len-1] = '\0';
	cur = 0;
	
	do
    {
		// find next '/'
		while (dirpath[cur] != '/' && cur < len)
			cur++;
		// if first char is '/' then again; (cur == len) -> last component
		if (cur == 0)
		{
			cur++;
			continue;
		}
		// check if path from 0 to cur is valid
		dirpath[cur] = '\0';
		if (stat(dirpath, &statbuf) == 0) // was _STAT
		{
			if (cur == len)
			{
				//ASSIGN(_lastError,
				//	   @"Could not create directory - already exists");
				return NO;
			}
		}
		else
		{
			// make new directory
			if (mkdir(dirpath, 0777) != 0)
			{
				NSString	*s;
				
				s = [NSString stringWithFormat: @"Could not create '%s' - '%@'",
					 dirpath, [NSError _last]];
				//ASSIGN(_lastError, s);
				return NO;
			}
			// if last directory and attributes then change
			if (cur == len && attributes != nil)
			{
				if ([self changeFileAttributes: attributes
										atPath: [self stringWithFileSystemRepresentation: dirpath
																				  length: cur]] == NO)
					return NO;
				if (needChown != nil)
				{
					if ([self changeFileAttributes: needChown
											atPath: [self stringWithFileSystemRepresentation: dirpath
																					  length: cur]] == NO)
					{
						NSLog(@"Failed to change ownership of '%s' to '%@'",
							  dirpath, NSUserName());
					}
				}
				return YES;
			}
		}
		dirpath[cur] = '/';
		cur++;
    }
	while (cur < len);
	
//#endif /* !MINGW */
	
	// change attributes of last directory
	if ([attributes count] == 0)
    {
		return YES;
    }
	return [self changeFileAttributes: attributes atPath: path];
}

/**
 * Creates a new file, and sets its attributes as specified.<br />
 * Initialises the file content with the specified data.<br />
 * Returns YES on success, NO on failure.
 */
- (BOOL) createFileAtPath: (NSString*)path
				 contents: (NSData*)contents
			   attributes: (NSDictionary*)attributes
{
//#if	defined(__MINGW32__)
//	const _CHAR *lpath = [self fileSystemRepresentationWithPath: path];
//	HANDLE fh;
//	DWORD	written = 0;
//	DWORD	len = [contents length];
//#else
	const char	*lpath;
	int	fd;
	int	len;
	int	written;
//#endif
	
	/* This is consistent with MacOSX - just return NO for an invalid path. */
	if ([path length] == 0)
		return NO;
	
//#if	defined(__MINGW32__)
//	fh = CreateFileW(lpath, GENERIC_WRITE, 0, 0, CREATE_ALWAYS,
//					 FILE_ATTRIBUTE_NORMAL, 0);
//	if (fh == INVALID_HANDLE_VALUE)
//    {
//		return NO;
//    }
//	else
//    {
//		if (len > 0)
//		{
//			WriteFile(fh, [contents bytes], len, &written, 0);
//		}
//		CloseHandle(fh);
//		if (attributes != nil
//			&& [self changeFileAttributes: attributes atPath: path] == NO)
//		{
//			return NO;
//		}
//		return YES;
//    }
//#else
	lpath = [self fileSystemRepresentationWithPath: path];
	
	fd = open(lpath, 0|O_WRONLY|O_TRUNC|O_CREAT, 0644); // sjc: 0 was GSBINIO (no O_BINARY love?)
	if (fd < 0)
    {
		return NO;
    }
	if (attributes != nil
		&& [self changeFileAttributes: attributes atPath: path] == NO)
    {
		close (fd);
		return NO;
    }
	
	/*
	 * If there is no file owner specified, and we are running setuid to
	 * root, then we assume we need to change ownership to correct user.
	 */
	if (attributes == nil || ([attributes fileOwnerAccountID] == nil // sjc: NSNotFound
							  && [attributes fileOwnerAccountName] == nil))
    {
		if (geteuid() == 0 && [@"root" isEqualToString: NSUserName()] == NO)
		{
			attributes = [NSDictionary dictionaryWithObjectsAndKeys:
						  NSFileOwnerAccountName, NSUserName(), nil];
			if (![self changeFileAttributes: attributes atPath: path])
			{
				NSLog(@"Failed to change ownership of '%@' to '%@'",
					  path, NSUserName());
			}
		}
    }
	len = [contents length];
	if (len > 0)
    {
		written = write(fd, [contents bytes], len);
    }
	else
    {
		written = 0;
    }
	close (fd);
//#endif
	return written == len;
}

/**
 * Returns the current working directory used by all instance of the file
 * manager in the current task.
 */
- (NSString*) currentDirectoryPath
{
	NSString *currentDir = nil;
	
//#if defined(__MINGW32__)
//	int len = GetCurrentDirectoryW(0, 0);
//	if (len > 0)
//    {
//		_CHAR *lpath = (_CHAR*)objc_calloc(len+10,sizeof(_CHAR));
//		
//		if (lpath != 0)
//		{
//			if (GetCurrentDirectoryW(len, lpath)>0)
//			{
//				NSString	*path;
//				
//				// Windows may count the trailing nul ... we don't want to.
//				if (len > 0 && lpath[len] == 0) len--;
//				path = [NSString stringWithCharacters: lpath length: len];
//				currentDir = path;
//			}
//			objc_free(lpath);
//		}
//    }
//#else
	char path[PATH_MAX];
//#ifdef HAVE_GETCWD
	if (getcwd(path, PATH_MAX-1) == 0)
		return nil;
//#else
//	if (getwd(path) == 0)
//		return nil;
//#endif /* HAVE_GETCWD */
	currentDir = [self stringWithFileSystemRepresentation: path
												   length: strlen(path)];
//#endif /* !MINGW */
	
	return currentDir;
}


/* These methods replace their non-error returning counterparts below. See the NSFileManagerFileOperationAdditions category below for methods that are dispatched to the NSFileManager instance's delegate.
 */
- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {}

/**
 * Copies the file or directory at source to destination, using a
 * handler object which should respond to
 * [NSObject-fileManager:willProcessPath:] and
 * [NSObject-fileManager:shouldProceedAfterError:] messages.<br />
 * Will not copy to a destination which already exists.
 */
- (BOOL) copyPath: (NSString*)source
		   toPath: (NSString*)destination
		  handler: (id)handler
{
	NSDictionary	*attrs;
	NSString	*fileType;
	
	if ([self fileExistsAtPath: destination] == YES)
    {
		return NO;
    }
	attrs = [self fileAttributesAtPath: source traverseLink: NO];
	if (attrs == nil)
    {
		return NO;
    }
	fileType = [attrs fileType];
	if ([fileType isEqualToString: NSFileTypeDirectory] == YES)
    {
		NSMutableDictionary	*mattrs;
		
		/* If destination directory is a descendant of source directory copying
		 isn't possible. */
		if ([[destination stringByAppendingString: @"/"]
			 hasPrefix: [source stringByAppendingString: @"/"]])
		{
			return NO;
		}
		
		[self _sendToHandler: handler willProcessPath: destination];
		
		/*
		 * Don't attempt to retain ownership of copy ... we want the copy
		 * to be owned by the current user.
		 */
		mattrs = [attrs mutableCopy];
		[mattrs removeObjectForKey: NSFileOwnerAccountID];
		[mattrs removeObjectForKey: NSFileGroupOwnerAccountID];
		[mattrs removeObjectForKey: NSFileGroupOwnerAccountName];
		[mattrs setObject: NSUserName() forKey: NSFileOwnerAccountName];
		attrs = [mattrs autorelease]; //AUTORELEASE(mattrs);
		
		if ([self createDirectoryAtPath: destination attributes: attrs] == NO)
		{
			return [self _proceedAccordingToHandler: handler
										   forError: nil // sjc: was _lastError
											 inPath: destination
										   fromPath: source
											 toPath: destination];
		}
		
		if ([self _copyPath: source toPath: destination handler: handler] == NO)
		{
			return NO;
		}
    }
	else if ([fileType isEqualToString: NSFileTypeSymbolicLink] == YES)
    {
		NSString	*path;
		BOOL	result;
		
		[self _sendToHandler: handler willProcessPath: source];
		
		path = [self pathContentOfSymbolicLinkAtPath: source];
		result = [self createSymbolicLinkAtPath: destination pathContent: path];
		if (result == NO)
		{
			result = [self _proceedAccordingToHandler: handler
											 forError: @"cannot link to file"
											   inPath: source
											 fromPath: source
											   toPath: destination];
			
			if (result == NO)
			{
				return NO;
			}
		}
    }
	else
    {
		[self _sendToHandler: handler willProcessPath: source];
		
		if ([self _copyFile: source toFile: destination handler: handler] == NO)
		{
			return NO;
		}
    }
	[self changeFileAttributes: attrs atPath: destination];
	return YES;
}


/* These methods replace their non-error returning counterparts below. See the NSFileManagerFileOperationAdditions category below for methods that are dispatched to the NSFileManager instance's delegate.
 */
- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {}

/**
 * Moves the file or directory at source to destination, using a
 * handler object which should respond to
 * [NSObject-fileManager:willProcessPath:] and
 * [NSObject-fileManager:shouldProceedAfterError:] messages.
 * Will not move to a destination which already exists.<br />
 */
- (BOOL) movePath: (NSString*)source
		   toPath: (NSString*)destination
		  handler: (id)handler
{
	BOOL		sourceIsDir;
	BOOL		fileExists;
	NSString	*destinationParent;
	unsigned int	sourceDevice;
	unsigned int	destinationDevice;
	const char	*sourcePath; // sjc: was _CHAR
	const char	*destPath; // sjc: was _CHAR
	
	sourcePath = [self fileSystemRepresentationWithPath: source];
	destPath = [self fileSystemRepresentationWithPath: destination];
	
	if ([self fileExistsAtPath: destination] == YES)
    {
		return NO;
    }
	fileExists = [self fileExistsAtPath: source isDirectory: &sourceIsDir];
	if (!fileExists)
    {
		return NO;
    }
	
	/* Check to see if the source and destination's parent are on the same
     physical device so we can perform a rename syscall directly. */
	sourceDevice = [[self fileSystemAttributesAtPath: source] fileSystemNumber];
	destinationParent = [destination stringByDeletingLastPathComponent];
	if ([destinationParent isEqual: @""])
		destinationParent = @".";
	destinationDevice
    = [[self fileSystemAttributesAtPath: destinationParent] fileSystemNumber];
	
	if (sourceDevice != destinationDevice)
    {
		/* If destination directory is a descendant of source directory moving
		 isn't possible. */
		if (sourceIsDir && [[destination stringByAppendingString: @"/"]
							hasPrefix: [source stringByAppendingString: @"/"]])
		{
			return NO;
		}
		
		if ([self copyPath: source toPath: destination handler: handler])
		{
			NSDictionary	*attributes;
			
			attributes = [self fileAttributesAtPath: source
									   traverseLink: NO];
			[self changeFileAttributes: attributes atPath: destination];
			return [self removeFileAtPath: source handler: handler];
		}
		else
		{
			return NO;
		}
    }
	else
    {
		/* source and destination are on the same device so we can simply
		 invoke rename on source. */
		[self _sendToHandler: handler willProcessPath: source];
		
		if (rename(sourcePath, destPath) == -1) // sjc: rename was _RENAME
		{
			return [self _proceedAccordingToHandler: handler
										   forError: @"cannot move file"
											 inPath: source
										   fromPath: source
											 toPath: destination];
		}
		return YES;
    }
	
	return NO;
}


/* These methods replace their non-error returning counterparts below. See the NSFileManagerFileOperationAdditions category below for methods that are dispatched to the NSFileManager instance's delegate.
 */
- (BOOL)linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {}

/**
 * <p>Links the file or directory at source to destination, using a
 * handler object which should respond to
 * [NSObject-fileManager:willProcessPath:] and
 * [NSObject-fileManager:shouldProceedAfterError:] messages.
 * </p>
 * <p>If the destination is a directory, the source path is linked
 * into that directory, otherwise the destination must not exist,
 * but its parent directory must exist and the source will be linked
 * into the parent as the name specified by the destination.
 * </p>
 * <p>If the source is a symbolic link, it is copied to the destination.<br />
 * If the source is a directory, it is copied to the destination and its
 * contents are linked into the new directory.<br />
 * Otherwise, a hard link is made from the destination to the source.
 * </p>
 */
- (BOOL) linkPath: (NSString*)source
		   toPath: (NSString*)destination
		  handler: (id)handler
{
//#ifdef HAVE_LINK
	NSDictionary	*attrs;
	NSString	*fileType;
	BOOL		isDir;
	
	if ([self fileExistsAtPath: destination isDirectory: &isDir] == YES
		&& isDir == YES)
    {
		destination = [destination stringByAppendingPathComponent:
					   [source lastPathComponent]];
    }
	
	attrs = [self fileAttributesAtPath: source traverseLink: NO];
	if (attrs == nil)
    {
		return NO;
    }
	
	[self _sendToHandler: handler willProcessPath: destination];
	
	fileType = [attrs fileType];
	if ([fileType isEqualToString: NSFileTypeDirectory] == YES)
    {
		/* If destination directory is a descendant of source directory linking
		 isn't possible because of recursion. */
		if ([[destination stringByAppendingString: @"/"]
			 hasPrefix: [source stringByAppendingString: @"/"]])
		{
			return NO;
		}
		
		if ([self createDirectoryAtPath: destination attributes: attrs] == NO)
		{
			return [self _proceedAccordingToHandler: handler
										   forError: nil //_lastError
											 inPath: destination
										   fromPath: source
											 toPath: destination];
		}
		
		if ([self _linkPath: source toPath: destination handler: handler] == NO)
		{
			return NO;
		}
    }
	else if ([fileType isEqual: NSFileTypeSymbolicLink])
    {
		NSString	*path;
		
		path = [self pathContentOfSymbolicLinkAtPath: source];
		if ([self createSymbolicLinkAtPath: destination
							   pathContent: path] == NO)
		{
			if ([self _proceedAccordingToHandler: handler
										forError: @"cannot create symbolic link"
										  inPath: source
										fromPath: source
										  toPath: destination] == NO)
			{
				return NO;
			}
		}
    }
	else
    {
		if (link([self fileSystemRepresentationWithPath: source],
				 [self fileSystemRepresentationWithPath: destination]) < 0)
		{
			if ([self _proceedAccordingToHandler: handler
										forError: @"cannot create hard link"
										  inPath: source
										fromPath: source
										  toPath: destination] == NO)
			{
				return NO;
			}
		}
    }
	[self changeFileAttributes: attrs atPath: destination];
	return YES;
//#else
//	return NO;	// Links not supported on this platform
//#endif
}


/* These methods replace their non-error returning counterparts below. See the NSFileManagerFileOperationAdditions category below for methods that are dispatched to the NSFileManager instance's delegate.
 */
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {}

/**
 * Removes the file or directory at path, using a
 * handler object which should respond to
 * [NSObject-fileManager:willProcessPath:] and
 * [NSObject-fileManager:shouldProceedAfterError:] messages.
 */
- (BOOL) removeFileAtPath: (NSString*)path
				  handler: handler
{
	BOOL		is_dir;
	const char	*lpath; // sjc: was _CHAR
	
	if ([path isEqualToString: @"."] || [path isEqualToString: @".."])
    {
		[NSException raise: NSInvalidArgumentException
					format: @"Attempt to remove illegal path"];
    }
	
	[self _sendToHandler: handler willProcessPath: path];
	
	lpath = [self fileSystemRepresentationWithPath: path];
	if (lpath == 0 || *lpath == 0)
    {
		return NO;
    }
	else
    {
//#if defined(__MINGW32__)
//		DWORD res;
//		
//		res = GetFileAttributesW(lpath);
//		
//		if (res == WIN32ERR)
//		{
//			return NO;
//		}
//		if (res & FILE_ATTRIBUTE_DIRECTORY)
//		{
//			is_dir = YES;
//		}
//		else
//		{
//			is_dir = NO;
//		}
//#else
		struct stat statbuf; // sjc: stat was _STATB
		
		if (lstat(lpath, &statbuf) != 0)
		{
			return NO;
		}
		is_dir = ((statbuf.st_mode & S_IFMT) == S_IFDIR);
//#endif /* MINGW */
    }
	
	if (!is_dir)
    {
//#if defined(__MINGW32__)
//		if (DeleteFileW(lpath) == FALSE)
//#else
			if (unlink(lpath) < 0)
//#endif
			{
				NSString	*message = [[NSError _last] localizedDescription];
				
				return [self _proceedAccordingToHandler: handler
											   forError: message
												 inPath: path];
			}
			else
			{
				return YES;
			}
    }
	else
    {
		NSArray   *contents = [self directoryContentsAtPath: path];
		unsigned	count = [contents count];
		unsigned	i;
		
		for (i = 0; i < count; i++)
		{
			NSString		*item;
			NSString		*next;
			BOOL			result;
			//CREATE_AUTORELEASE_POOL(arp);
			NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
			
			item = [contents objectAtIndex: i];
			next = [path stringByAppendingPathComponent: item];
			result = [self removeFileAtPath: next handler: handler];
			[arp drain];//RELEASE(arp);
			if (result == NO)
			{
				return NO;
			}
		}
		
		if (rmdir([self fileSystemRepresentationWithPath: path]) < 0) // sjc: rmdir was _RMDIR
		{
			NSString	*message = [[NSError _last] localizedDescription];
			
			return [self _proceedAccordingToHandler: handler
										   forError: message
											 inPath: path];
		}
		else
		{
			return YES;
		}
    }
}

/**
 * Returns YES if a file (or directory etc) exists at the specified path.
 */
- (BOOL) fileExistsAtPath: (NSString*)path
{
	return [self fileExistsAtPath: path isDirectory: 0];
}

/**
 * Returns YES if a file (or directory etc) exists at the specified path.<br />
 * If the isDirectory argument is not a nul pointer, stores a flag
 * in the location it points to, indicating whether the file is a
 * directory or not.<br />
 */
- (BOOL) fileExistsAtPath: (NSString*)path isDirectory: (BOOL*)isDirectory
{
	const char *lpath = [self fileSystemRepresentationWithPath: path];
	
	if (isDirectory != 0)
    {
		*isDirectory = NO;
    }
	
	if (lpath == 0 || *lpath == '\0') // sjc: '\0' was _NUL
    {
		return NO;
    }
	
//#if defined(__MINGW32__)
//    {
//		DWORD res;
//		
//		res = GetFileAttributesW(lpath);
//		
//		if (res == WIN32ERR)
//		{
//			return NO;
//		}
//		if (isDirectory != 0)
//		{
//			if (res & FILE_ATTRIBUTE_DIRECTORY)
//			{
//				*isDirectory = YES;
//			}
//		}
//		return YES;
//    }
//#else
    {
		struct stat statbuf; // sjc: stat was _STATB
		
		if (stat(lpath, &statbuf) != 0) // sjc: stat was _STATB
		{
			return NO;
		}
		
		if (isDirectory)
		{
			if ((statbuf.st_mode & S_IFMT) == S_IFDIR)
			{
				*isDirectory = YES;
			}
		}
		
		return YES;
    }
//#endif /* MINGW */
}

/**
 * Returns YES if a file (or directory etc) exists at the specified path
 * and is readable.
 */
- (BOOL) isReadableFileAtPath: (NSString*)path
{
	const char* lpath = [self fileSystemRepresentationWithPath: path];
	
	if (lpath == 0 || *lpath == '\0') // sjc: '\0' was _NUL
    {
		return NO;
    }
	
//#if defined(__MINGW32__)
//    {
//		DWORD res;
//		
//		res = GetFileAttributesW(lpath);
//		
//		if (res == WIN32ERR)
//		{
//			return NO;
//		}
//		return YES;
//    }
//#else
    {
		if (access(lpath, R_OK) == 0)
		{
			return YES;
		}
		return NO;
    }
//#endif
}

/**
 * Returns YES if a file (or directory etc) exists at the specified path
 * and is writable.
 */
- (BOOL) isWritableFileAtPath: (NSString*)path
{
	const char* lpath = [self fileSystemRepresentationWithPath: path];
	
	if (lpath == 0 || *lpath == '\0') // sjc: '\0' was _NUL
    {
		return NO;
    }
	
//#if defined(__MINGW32__)
//    {
//		DWORD res;
//		
//		res = GetFileAttributesW(lpath);
//		
//		if (res == WIN32ERR)
//		{
//			return NO;
//		}
//		if (res & FILE_ATTRIBUTE_READONLY)
//		{
//			return NO;
//		}
//		return YES;
//    }
//#else
    {
		if (access(lpath, W_OK) == 0)
		{
			return YES;
		}
		return NO;
    }
//#endif
}

/**
 * Returns YES if a file (or directory etc) exists at the specified path
 * and is executable (if a directory is executable, you can access its
 * contents).
 */
- (BOOL) isExecutableFileAtPath: (NSString*)path
{
	const char* lpath = [self fileSystemRepresentationWithPath: path];
	
	if (lpath == 0 || *lpath == '\0') // sjc: '\0' was _NUL
    {
		return NO;
    }
	
//#if defined(__MINGW32__)
//    {
//		DWORD res;
//		
//		res = GetFileAttributesW(lpath);
//		
//		if (res == WIN32ERR)
//		{
//			return NO;
//		}
//		// TODO: Actually should check all extensions in env var PATHEXT
//		if ([[[path pathExtension] lowercaseString] isEqualToString: @"exe"])
//		{
//			return YES;
//		}
//		/* FIXME: On unix, directory accessible == executable, so we simulate that
//		 here for Windows. Is there a better check for directory access? */
//		if (res & FILE_ATTRIBUTE_DIRECTORY)
//		{
//			return YES;
//		}
//		return NO;
//    }
//#else
    {
		if (access(lpath, X_OK) == 0)
		{
			return YES;
		}
		return NO;
    }
//#endif
}

/**
 * Returns YES if a file (or directory etc) exists at the specified path
 * and is deletable.
 */
- (BOOL) isDeletableFileAtPath: (NSString*)path
{
	const char* lpath = [self fileSystemRepresentationWithPath: path];
	
	if (lpath == 0 || *lpath == '\0') // sjc: '\0' was _NUL
    {
		return NO;
    }
	
//#if defined(__MINGW32__)
//	// TODO - handle directories
//    {
//		DWORD res;
//		
//		res = GetFileAttributesW(lpath);
//		
//		if (res == WIN32ERR)
//		{
//			return NO;
//		}
//		return (res & FILE_ATTRIBUTE_READONLY) ? NO : YES;
//    }
//#else
    {
		// TODO - handle directories
		path = [path stringByDeletingLastPathComponent];
		if ([path length] == 0)
		{
			path = @".";
		}
		lpath = [self fileSystemRepresentationWithPath: path];
		
		if (access(lpath, X_OK | W_OK) == 0)
		{
			return YES;
		}
		return NO;
    }
//#endif
}


/**
 * If a file (or directory etc) exists at the specified path, and can be
 * queried for its attributes, this method returns a dictionary containing
 * the various attributes of that file.  Otherwise nil is returned.<br />
 * If the flag is NO and the file is a symbolic link, the attributes of
 * the link itself (rather than the file it points to) are returned.<br />
 * <p>
 *   The dictionary keys for attributes are -
 * </p>
 * <deflist>
 *   <term><code>NSFileAppendOnly</code></term>
 *   <desc>NSNumber ... boolean</desc>
 *   <term><code>NSFileCreationDate</code></term>
 *   <desc>NSDate when the file was created (if supported)</desc>
 *   <term><code>NSFileDeviceIdentifier</code></term>
 *   <desc>NSNumber (identifies the device on which the file is stored)</desc>
 *   <term><code>NSFileExtensionHidden</code></term>
 *   <desc>NSNumber ... boolean</desc>
 *   <term><code>NSFileGroupOwnerAccountName</code></term>
 *   <desc>NSString name of the file group</desc>
 *   <term><code>NSFileGroupOwnerAccountID</code></term>
 *   <desc>NSNumber ID of the file group</desc>
 *   <term><code>NSFileHFSCreatorCode</code></term>
 *   <desc>NSNumber not used</desc>
 *   <term><code>NSFileHFSTypeCode</code></term>
 *   <desc>NSNumber not used</desc>
 *   <term><code>NSFileImmutable</code></term>
 *   <desc>NSNumber ... boolean</desc>
 *   <term><code>NSFileModificationDate</code></term>
 *   <desc>NSDate when the file was last modified</desc>
 *   <term><code>NSFileOwnerAccountName</code></term>
 *   <desc>NSString name of the file owner</desc>
 *   <term><code>NSFileOwnerAccountID</code></term>
 *   <desc>NSNumber ID of the file owner</desc>
 *   <term><code>NSFilePosixPermissions</code></term>
 *   <desc>NSNumber posix access permissions mask</desc>
 *   <term><code>NSFileReferenceCount</code></term>
 *   <desc>NSNumber number of links to this file</desc>
 *   <term><code>NSFileSize</code></term>
 *   <desc>NSNumber size of the file in bytes</desc>
 *   <term><code>NSFileSystemFileNumber</code></term>
 *   <desc>NSNumber the identifier for the file on the filesystem</desc>
 *   <term><code>NSFileSystemNumber</code></term>
 *   <desc>NSNumber the filesystem on which the file is stored</desc>
 *   <term><code>NSFileType</code></term>
 *   <desc>NSString the type of file</desc>
 * </deflist>
 * <p>
 *   The [NSDictionary] class also has a set of convenience accessor methods
 *   which enable you to get at file attribute information more efficiently
 *   than using the keys above to extract it.  You should generally
 *   use the accessor methods where they are available.
 * </p>
 * <list>
 *   <item>[NSDictionary-fileCreationDate]</item>
 *   <item>[NSDictionary-fileExtensionHidden]</item>
 *   <item>[NSDictionary-fileHFSCreatorCode]</item>
 *   <item>[NSDictionary-fileHFSTypeCode]</item>
 *   <item>[NSDictionary-fileIsAppendOnly]</item>
 *   <item>[NSDictionary-fileIsImmutable]</item>
 *   <item>[NSDictionary-fileSize]</item>
 *   <item>[NSDictionary-fileType]</item>
 *   <item>[NSDictionary-fileOwnerAccountName]</item>
 *   <item>[NSDictionary-fileOwnerAccountID]</item>
 *   <item>[NSDictionary-fileGroupOwnerAccountName]</item>
 *   <item>[NSDictionary-fileGroupOwnerAccountID]</item>
 *   <item>[NSDictionary-fileModificationDate]</item>
 *   <item>[NSDictionary-filePosixPermissions]</item>
 *   <item>[NSDictionary-fileSystemNumber]</item>
 *   <item>[NSDictionary-fileSystemFileNumber]</item>
 * </list>
 */

/* "attributesOfItemAtPath:error: returns an NSDictionary of key/value pairs containing the attributes of the item (file, directory, symlink, etc.) at the path in question. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse an initial symlink.
 
	"This method replaces fileAttributesAtPath:traverseLink:."
 */
/*
 *	Unfortunately we can't wrap fileAttributesAtPath:traverseLink: around this method
 *	because it couldn't honour a traverseLink: YES situation. This is basically the method
 *	below without link tr
 */
- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error 
{
	struct stat statbuf;
	const char *lpath = [self fileSystemRepresentationWithPath: path];
	
	if (lpath == 0 || *lpath == 0) return nil;
	
	if (lstat(lpath, &statbuf) != 0) //  was &d->statbuf
	{
		if( error != nil )
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];
		return nil;
	}

	PF_RETURN_TEMP( _PFDictionaryFromStat(statbuf) )
}



- (NSDictionary*) fileAttributesAtPath: (NSString*)path traverseLink: (BOOL)flag
{
	struct stat statbuf;
	const char *lpath = [self fileSystemRepresentationWithPath: path];
	
	if (lpath == 0 || *lpath == 0) return nil;
	
	if (flag == NO) // return info for links
	{
		if (lstat(lpath, &statbuf) != 0) //  was &d->statbuf
			return nil;
	}
	else
		if (stat(lpath, &statbuf) != 0) // was &d->statbuf
			return nil;
	PF_RETURN_TEMP( _PFDictionaryFromStat(statbuf) ) //AUTORELEASE(d);
}

/**
 * Returns a dictionary containing the filesystem attributes for the
 * specified path (or nil if the path is not valid).<br />
 * <deflist>
 *   <term><code>NSFileSystemSize</code></term>
 *   <desc>NSNumber the size of the filesystem in bytes</desc>
 *   <term><code>NSFileSystemFreeSize</code></term>
 *   <desc>NSNumber the amount of unused space on the filesystem in bytes</desc>
 *   <term><code>NSFileSystemNodes</code></term>
 *   <desc>NSNumber the number of nodes in use to store files</desc>
 *   <term><code>NSFileSystemFreeNodes</code></term>
 *   <desc>NSNumber the number of nodes available to create files</desc>
 *   <term><code>NSFileSystemNumber</code></term>
 *   <desc>NSNumber the identifying number for the filesystem</desc>
 * </deflist>
 */
- (NSDictionary*) fileSystemAttributesAtPath: (NSString*)path
{
	return [self attributesOfFileSystemForPath: path error: NULL];
}

/* attributesOfFilesystemForPath:error: returns an NSDictionary of key/value pairs containing the attributes of the filesystem containing the provided path. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse an initial symlink.
 
 This method replaces fileSystemAttributesAtPath:.
 */
- (NSDictionary *)attributesOfFileSystemForPath:(NSString *)path error:(NSError **)error
{
//#if defined(__MINGW32__)
//	unsigned long long totalsize, freesize;
//	id  values[5];
//	id	keys[5] = {
//		NSFileSystemSize,
//		NSFileSystemFreeSize,
//		NSFileSystemNodes,
//		NSFileSystemFreeNodes,
//		NSFileSystemNumber
//	};
//	DWORD SectorsPerCluster, BytesPerSector, NumberFreeClusters;
//	DWORD TotalNumberClusters;
//	const _CHAR *lpath = [self fileSystemRepresentationWithPath: path];
//	
//	if (!GetDiskFreeSpaceW(lpath, &SectorsPerCluster,
//						   &BytesPerSector, &NumberFreeClusters, &TotalNumberClusters))
//    {
//		return nil;
//    }
//	
//	totalsize = (unsigned long long)TotalNumberClusters
//    * (unsigned long long)SectorsPerCluster
//    * (unsigned long long)BytesPerSector;
//	freesize = (unsigned long long)NumberFreeClusters
//    * (unsigned long long)SectorsPerCluster
//    * (unsigned long long)BytesPerSector;
//	
//	values[0] = [NSNumber numberWithUnsignedLongLong: totalsize];
//	values[1] = [NSNumber numberWithUnsignedLongLong: freesize];
//	values[2] = [NSNumber numberWithLong: LONG_MAX];
//	values[3] = [NSNumber numberWithLong: LONG_MAX];
//	values[4] = [NSNumber numberWithUnsignedInt: 0];
//	
//	return [NSDictionary dictionaryWithObjects: values forKeys: keys count: 5];
//	
//#else
//#if defined(HAVE_SYS_VFS_H) || defined(HAVE_SYS_STATFS_H) || defined(HAVE_SYS_MOUNT_H)
	struct stat statbuf; // sjc: stat was _STATB
//#ifdef HAVE_STATVFS
	struct statvfs statfsbuf;
//#else
//	struct statfs statfsbuf;
//#endif
	unsigned long long totalsize, freesize;
	unsigned long blocksize;
	const char* lpath = [self fileSystemRepresentationWithPath: path];
	
	id  values[5];
	id	keys[5] = {
		NSFileSystemSize,
		NSFileSystemFreeSize,
		NSFileSystemNodes,
		NSFileSystemFreeNodes,
		NSFileSystemNumber
	};
	
	if (stat(lpath, &statbuf) != 0) // sjc: stat was _STAT
    {
		if( error != nil )
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];
		//NSLog(@"NSFileManager", @"stat failed for '%s' ... %@", // sjc: was NSDebugMLLog
					 //lpath, [NSError _last]);
		return nil;
    }
//#ifdef HAVE_STATVFS
	if (statvfs(lpath, &statfsbuf) != 0)
    {
		if( error != nil )
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];
		//NSDebugMLLog(@"NSFileManager", @"statvfs failed for '%s' ... %@",
		//			 lpath, [NSError _last]);
		return nil;
    }
	blocksize = statfsbuf.f_frsize;
//#else
//	if (statfs(lpath, &statfsbuf) != 0)
//    {
//		NSDebugMLLog(@"NSFileManager", @"statfs failed for '%s' ... %@",
//					 lpath, [NSError _last]);
//		return nil;
//    }
//	blocksize = statfsbuf.f_bsize;
//#endif
	
	totalsize = (unsigned long long) blocksize
    * (unsigned long long) statfsbuf.f_blocks;
	freesize = (unsigned long long) blocksize
    * (unsigned long long) statfsbuf.f_bavail;
	
	values[0] = [NSNumber numberWithUnsignedLongLong: totalsize];
	values[1] = [NSNumber numberWithUnsignedLongLong: freesize];
	values[2] = [NSNumber numberWithLong: statfsbuf.f_files];
	values[3] = [NSNumber numberWithLong: statfsbuf.f_ffree];
	values[4] = [NSNumber numberWithUnsignedLong: statbuf.st_dev];
	
	return [NSDictionary dictionaryWithObjects: values forKeys: keys count: 5];
//#else
//	NSDebugMLLog(@"NSFileManager", @"no support for filesystem attributes");
//	return nil;
//#endif
//#endif /* MINGW */
}


/**
 * Returns an array of the contents of the specified directory.<br />
 * The listing does <strong>not</strong> recursively list subdirectories.<br />
 * The special files '.' and '..' are not listed.<br />
 * Indicates an error by returning nil (eg. if path is not a directory or
 * it can't be read for some reason).
 */
- (NSArray*) directoryContentsAtPath: (NSString*)path
{
	return [self contentsOfDirectoryAtPath: path error: NULL];
}

/* "contentsOfDirectoryAtPath:error: returns an NSArray of NSStrings representing the filenames of the items in the directory. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
 
	"This method replaces directoryContentsAtPath:"
 */
- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error
{
	NSDirectoryEnumerator	*direnum;
	NSMutableArray	*content;
	IMP			nxtImp;
	IMP			addImp;
	BOOL			is_dir;
	
	/*
	 * See if this is a directory (don't follow links).
	 */
	if ([self fileExistsAtPath: path isDirectory: &is_dir] == NO || is_dir == NO)
    {
#warning find out what error code and domain this shou
		if( error != nil ) 
			*error = [NSError errorWithDomain: NSCocoaErrorDomain code: 0 userInfo: nil];
		return nil;
    }
	/* We initialize the directory enumerator with justContents == YES,
     which tells the NSDirectoryEnumerator code that we only enumerate
     the contents non-recursively once, and exit.  NSDirectoryEnumerator
     can perform some optimisations using this assumption. */
	direnum = [[GSDirectoryEnumerator alloc] initWithDirectoryPath: path
										 recurseIntoSubdirectories: NO
													followSymlinks: NO
													  justContents: YES
															   for: self];
	content = [NSMutableArray arrayWithCapacity: 128];
	
	nxtImp = [direnum methodForSelector: @selector(nextObject)];
	addImp = [content methodForSelector: @selector(addObject:)];
	
	while ((path = (*nxtImp)(direnum, @selector(nextObject))) != nil)
    {
		(*addImp)(content, @selector(addObject:), path);
    }
	[direnum release]; //RELEASE(direnum);
	
	return [content mutableCopyWithZone: nil]; //[content makeImmutableCopyOnFail: NO];
}

/**
 * Returns the name of the file or directory at path.  Converts it into
 * a format for display to an end user.  This may render it unusable as
 * part of a file/path name.<br />
 * For instance, if a user has elected not to see file extensions, this
 * method may return filenames with the extension removed.<br />
 * The default operation is to return the result of calling
 * [NSString-lastPathComponent] on the path.
 */
- (NSString*) displayNameAtPath: (NSString*)path
{
	return [path lastPathComponent];
}

/**
 * Returns an enumerator which can be used to return each item with
 * the directory at path in turn.<br />
 * The enumeration is recursive ... following all nested subdirectories.
 */
- (NSDirectoryEnumerator*) enumeratorAtPath: (NSString*)path
{
	return [[[NSDirectoryEnumerator alloc] // sjc: removed wrapped AUTORELEASE
						initWithDirectoryPath: path
						recurseIntoSubdirectories: YES
						followSymlinks: NO
						justContents: NO
						for: self] autorelease];
}


/**
 * Returns an array containing the (relative) paths of all the items
 * in the directory at path.<br />
 * The listing follows all subdirectories, so it can produce a very
 * large array ... use with care.
 */
- (NSArray*) subpathsAtPath: (NSString*)path
{
	return [self subpathsOfDirectoryAtPath: path error: NULL];
}

/* subpathsOfDirectoryAtPath:error: returns an NSArray of NSStrings represeting the filenames of the items in the specified directory and all its subdirectories recursively. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
 
 This method replaces subpathsAtPath:
 */
- (NSArray *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error
{
	NSDirectoryEnumerator	*direnum;
	NSMutableArray	*content;
	BOOL			isDir;
	IMP			nxtImp;
	IMP			addImp;
	
	if (![self fileExistsAtPath: path isDirectory: &isDir] || !isDir)
    {
#warning find out what errors these should return
		if( error != NULL )
			*error = [NSError errorWithDomain: NSCocoaErrorDomain code: 0 userInfo: nil];
		return nil;
    }
	direnum = [[GSDirectoryEnumerator alloc] initWithDirectoryPath: path
										 recurseIntoSubdirectories: YES
													followSymlinks: NO
													  justContents: NO
															   for: self];
	content = [NSMutableArray arrayWithCapacity: 128];
	
	nxtImp = [direnum methodForSelector: @selector(nextObject)];
	addImp = [content methodForSelector: @selector(addObject:)];
	
	while ((path = (*nxtImp)(direnum, @selector(nextObject))) != nil)
    {
		(*addImp)(content, @selector(addObject:), path);
    }
	
	[direnum release]; //RELEASE(direnum);
	
	return [content mutableCopyWithZone: nil]; //[content makeImmutableCopyOnFail: NO];
}


/**
 * Creates a symbolic link at path which links to the location
 * specified by otherPath.
 */
- (BOOL) createSymbolicLinkAtPath: (NSString*)path
					  pathContent: (NSString*)otherPath
{
	return [self createSymbolicLinkAtPath: path withDestinationPath: otherPath error: NULL];
}

/* "createSymbolicLinkAtPath:withDestination:error: returns YES if the symbolic link that point at 'destPath' was able to be created at the location specified by 'path'. If this method returns NO, the link was unable to be created and an NSError will be returned by reference in the 'error' parameter. This method does not traverse an initial symlink.
 
	"This method replaces createSymbolicLinkAtPath:pathContent:"
 */
- (BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError **)error
{
//#ifdef HAVE_SYMLINK
	const char* newpath = [self fileSystemRepresentationWithPath: path];
	const char* oldpath = [self fileSystemRepresentationWithPath: destPath];
	
	//return (symlink(oldpath, newpath) == 0);
	if( symlink(oldpath, newpath) == 0)
		return YES;
	
	if( error != NULL )
		*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];
	return NO;
//#else
//	return NO;
//#endif
}




/**
 * Returns the name of the file or directory that the symbolic link
 * at path points to.
 */
- (NSString*) pathContentOfSymbolicLinkAtPath: (NSString*)path
{
	return [self destinationOfSymbolicLinkAtPath: path error: NULL];
}

/* destinationOfSymbolicLinkAtPath:error: returns an NSString containing the path of the item pointed at by the symlink specified by 'path'. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. This method does not traverse an initial symlink.
 
 This method replaces pathContentOfSymbolicLinkAtPath:
 */
- (NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error
{
//#ifdef HAVE_READLINK
	char  buf[PATH_MAX];
	const char* lpath = [self fileSystemRepresentationWithPath: path];
	int   llen = readlink(lpath, buf, PATH_MAX-1);
	
	if (llen > 0)
    {
		return [self stringWithFileSystemRepresentation: buf length: llen];
    }
	else
    {
		if( error != NULL )
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil];
		return nil;
    }
//#else
//	return nil;
//#endif
}



- (const char*) fileSystemRepresentationWithPath: (NSString*)path
{
	return
    (const char*)[path cStringUsingEncoding: [NSString defaultCStringEncoding]];
}
- (NSString*) stringWithFileSystemRepresentation: (const char*)string
										  length: (unsigned int)len
{
	return [[[NSString allocWithZone: NSDefaultMallocZone()]  // AUTORELEASE
						initWithBytes: string length: len encoding: [NSString defaultCStringEncoding]] autorelease];
}

/*
 *	End of methods taken from GNUStep
 */

/*
 *	To avoid sub-classing -- and because we don't want to add ivars -- we'll keep delegates
 *	in an external CFMutableDictionary. 
 */
- (void)setDelegate:(id)delegate 
{
	if( _PFFileManagerDelegates == nil )
		_PFFileManagerDelegates = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, NULL, NULL );
	CFDictionarySetValue( _PFFileManagerDelegates, (const void *)self, (const void *)delegate );
}

- (id)delegate 
{ 
	if( _PFFileManagerDelegates != nil )
		return (id)CFDictionaryGetValue( _PFFileManagerDelegates, (const void *)self );
	return nil; 
}


@end /* NSFileManager */




@implementation NSFileManager (PrivateMethods)

- (BOOL) _copyFile: (NSString*)source
			toFile: (NSString*)destination
		   handler: (id)handler
{
//#if defined(__MINGW32__)
//	if (CopyFileW([self fileSystemRepresentationWithPath: source],
//				  [self fileSystemRepresentationWithPath: destination], NO))
//    {
//		return YES;
//    }
//	
//	return [self _proceedAccordingToHandler: handler
//								   forError: @"cannot copy file"
//									 inPath: source
//								   fromPath: source
//									 toPath: destination];
//	
//#else
	NSDictionary	*attributes;
	int		i;
	int		bufsize = 8096;
	int		sourceFd;
	int		destFd;
	int		fileSize;
	int		fileMode;
	int		rbytes;
	int		wbytes;
	char		buffer[bufsize];
	
	/* Assumes source is a file and exists! */
	NSAssert1 ([self fileExistsAtPath: source],
			   @"source file '%@' does not exist!", source);
	
	attributes = [self fileAttributesAtPath: source traverseLink: NO];
	NSAssert1 (attributes, @"could not get the attributes for file '%@'",
			   source);
	
	fileSize = [attributes fileSize];
	fileMode = [attributes filePosixPermissions];
	
	/* Open the source file. In case of error call the handler. */
	sourceFd = open([self fileSystemRepresentationWithPath: source],
					0|O_RDONLY); // sjc: 0 was GSBINO
	if (sourceFd < 0)
    {
		return [self _proceedAccordingToHandler: handler
									   forError: @"cannot open file for reading"
										 inPath: source
									   fromPath: source
										 toPath: destination];
    }
	
	/* Open the destination file. In case of error call the handler. */
	destFd = open([self fileSystemRepresentationWithPath: destination],
				  0|O_WRONLY|O_CREAT|O_TRUNC, fileMode); // sjc: 0 was GSBINIO
	if (destFd < 0)
    {
		close (sourceFd);
		
		return [self _proceedAccordingToHandler: handler
									   forError:  @"cannot open file for writing"
										 inPath: destination
									   fromPath: source
										 toPath: destination];
    }
	
	/* Read bufsize bytes from source file and write them into the destination
     file. In case of errors call the handler and abort the operation. */
	for (i = 0; i < fileSize; i += rbytes)
    {
		rbytes = read (sourceFd, buffer, bufsize);
		if (rbytes < 0)
		{
			close (sourceFd);
			close (destFd);
			
			return [self _proceedAccordingToHandler: handler
										   forError: @"cannot read from file"
											 inPath: source
										   fromPath: source
											 toPath: destination];
		}
		
		wbytes = write (destFd, buffer, rbytes);
		if (wbytes != rbytes)
		{
			close (sourceFd);
			close (destFd);
			
			return [self _proceedAccordingToHandler: handler
										   forError: @"cannot write to file"
											 inPath: destination
										   fromPath: source
											 toPath: destination];
        }
    }
	close (sourceFd);
	close (destFd);
	
	return YES;
//#endif
}

- (BOOL) _copyPath: (NSString*)source
			toPath: (NSString*)destination
		   handler: handler
{
	NSDirectoryEnumerator	*enumerator;
	NSString		*dirEntry;
	//CREATE_AUTORELEASE_POOL(pool);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	enumerator = [self enumeratorAtPath: source];
	while ((dirEntry = [enumerator nextObject]))
    {
		NSString		*sourceFile;
		NSString		*fileType;
		NSString		*destinationFile;
		NSDictionary	*attributes;
		
		attributes = [enumerator fileAttributes];
		fileType = [attributes fileType];
		sourceFile = [source stringByAppendingPathComponent: dirEntry];
		destinationFile
		= [destination stringByAppendingPathComponent: dirEntry];
		
		[self _sendToHandler: handler willProcessPath: sourceFile];
		
		if ([fileType isEqual: NSFileTypeDirectory])
		{
			BOOL	dirOK;
			
			dirOK = [self createDirectoryAtPath: destinationFile
									 attributes: attributes];
			if (dirOK == NO)
			{
				if (![self _proceedAccordingToHandler: handler
											 forError: nil //_lastError
											   inPath: destinationFile
											 fromPath: sourceFile
											   toPath: destinationFile])
                {
					return NO;
                }
				/*
				 * We may have managed to create the directory but not set
				 * its attributes ... if so we can continue copying.
				 */
				if (![self fileExistsAtPath: destinationFile isDirectory: &dirOK])
				{
					dirOK = NO;
				}
			}
			if (dirOK == YES)
			{
				[enumerator skipDescendents];
				if (![self _copyPath: sourceFile
							  toPath: destinationFile
							 handler: handler])
					return NO;
			}
		}
		else if ([fileType isEqual: NSFileTypeRegular])
		{
			if (![self _copyFile: sourceFile
						  toFile: destinationFile
						 handler: handler])
				return NO;
		}
		else if ([fileType isEqual: NSFileTypeSymbolicLink])
		{
			NSString	*path;
			
			path = [self pathContentOfSymbolicLinkAtPath: sourceFile];
			if (![self createSymbolicLinkAtPath: destinationFile
									pathContent: path])
			{
				if (![self _proceedAccordingToHandler: handler
											 forError: @"cannot create symbolic link"
											   inPath: sourceFile
											 fromPath: sourceFile
											   toPath: destinationFile])
                {
					return NO;
                }
			}
		}
		else
		{
			NSString	*s;
			
			s = [NSString stringWithFormat: @"cannot copy file type '%@'",
				 fileType];
			//ASSIGN(_lastError, s);
			NSLog(@"%@: %@", sourceFile, s);
			continue;
		}
		[self changeFileAttributes: attributes atPath: destinationFile];
    }
	[pool drain]; //RELEASE(pool);
	
	return YES;
}

- (BOOL) _linkPath: (NSString*)source
			toPath: (NSString*)destination
		   handler: handler
{
//#ifdef HAVE_LINK
	NSDirectoryEnumerator	*enumerator;
	NSString		*dirEntry;
	//CREATE_AUTORELEASE_POOL(pool);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	enumerator = [self enumeratorAtPath: source];
	while ((dirEntry = [enumerator nextObject]))
    {
		NSString		*sourceFile;
		NSString		*fileType;
		NSString		*destinationFile;
		NSDictionary	*attributes;
		
		attributes = [enumerator fileAttributes];
		fileType = [attributes fileType];
		sourceFile = [source stringByAppendingPathComponent: dirEntry];
		destinationFile
		= [destination stringByAppendingPathComponent: dirEntry];
		
		[self _sendToHandler: handler willProcessPath: sourceFile];
		
		if ([fileType isEqual: NSFileTypeDirectory] == YES)
		{
			if ([self createDirectoryAtPath: destinationFile
								 attributes: attributes] == NO)
			{
				if ([self _proceedAccordingToHandler: handler
											forError: nil //_lastError
											  inPath: destinationFile
											fromPath: sourceFile
											  toPath: destinationFile] == NO)
                {
					return NO;
                }
			}
			else
			{
				[enumerator skipDescendents];
				if ([self _linkPath: sourceFile
							 toPath: destinationFile
							handler: handler] == NO)
				{
					return NO;
				}
			}
		}
		else if ([fileType isEqual: NSFileTypeSymbolicLink])
		{
			NSString	*path;
			
			path = [self pathContentOfSymbolicLinkAtPath: sourceFile];
			if ([self createSymbolicLinkAtPath: destinationFile
								   pathContent: path] == NO)
			{
				if ([self _proceedAccordingToHandler: handler
											forError: @"cannot create symbolic link"
											  inPath: sourceFile
											fromPath: sourceFile
											  toPath: destinationFile] == NO)
                {
					return NO;
                }
			}
		}
		else
		{
			if (link([self fileSystemRepresentationWithPath: sourceFile],
					 [self fileSystemRepresentationWithPath: destinationFile]) < 0)
			{
				if ([self _proceedAccordingToHandler: handler
											forError: @"cannot create hard link"
											  inPath: sourceFile
											fromPath: sourceFile
											  toPath: destinationFile] == NO)
                {
					return NO;
                }
			}
		}
		[self changeFileAttributes: attributes atPath: destinationFile];
    }
	RELEASE(pool);
	return YES;
//#else
//	return NO;
//#endif
}

- (void) _sendToHandler: (id) handler
        willProcessPath: (NSString*) path
{
	if ([handler respondsToSelector: @selector (fileManager:willProcessPath:)])
    {
		[handler fileManager: self willProcessPath: path];
    }
}

- (BOOL) _proceedAccordingToHandler: (id) handler
                           forError: (NSString*) error
                             inPath: (NSString*) path
{
	if ([handler respondsToSelector:
		 @selector (fileManager:shouldProceedAfterError:)])
    {
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   path, @"Path",
								   error, @"Error", nil];
		return [handler fileManager: self
			shouldProceedAfterError: errorInfo];
    }
	return NO;
}

- (BOOL) _proceedAccordingToHandler: (id) handler
                           forError: (NSString*) error
                             inPath: (NSString*) path
                           fromPath: (NSString*) fromPath
                             toPath: (NSString*) toPath
{
	if ([handler respondsToSelector:
		 @selector (fileManager:shouldProceedAfterError:)])
    {
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   path, @"Path",
								   fromPath, @"FromPath",
								   toPath, @"ToPath",
								   error, @"Error", nil];
		return [handler fileManager: self
			shouldProceedAfterError: errorInfo];
    }
	return NO;
}

@end /* NSFileManager (PrivateMethods) */
