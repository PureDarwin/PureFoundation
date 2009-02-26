/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSHFSFileTypes.m
 *
 *	NSHFSFileTypes
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	Really, I created this file in the hope that the code would magically appear
 *	in it. It didn't. I'm not even sure if this info in held on Darwin.
 */

#import "NSHFSFileTypes.h"

// Given an HFS file type code, return a string that represents the file type.  The string will have been autoreleased.  The format of the string is a private implementation detail, but such strings are suitable for inclusion in arrays that also contain file name extension strings.  Several Cocoa API methods take such arrays.
NSString *NSFileTypeForHFSTypeCode(OSType hfsFileTypeCode)
{
	
}

// Given a string of the sort encoded by NSFileTypeForHFSTypeCode(), return the corresponding HFS file type code.  Return zero otherwise.
OSType NSHFSTypeCodeFromFileType(NSString *fileTypeString)
{
	
}

// Given the full absolute path of a file, return a string that represents the file's HFS file type as described above, or nil if the operation is not successful.  The string will have been autoreleased.
NSString *NSHFSTypeOfFile(NSString *fullFilePath)
{
	
}
