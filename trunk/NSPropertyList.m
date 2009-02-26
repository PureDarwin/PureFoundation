/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSPropertyList.m
 *
 *	NSPropertyList
 *
 *	Created by Stuart Crook on 29/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSPropertyList.h"

/*
 *	"The NSPropertyListSerialization class provides methods that convert property list objects to 
 *	and from several serialized formats."
 *
 *	ivars: void *reserved[6]
 */
@implementation NSPropertyListSerialization

+(id)alloc { return nil; } // shouldn't be created...

+ (BOOL)propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format
{
	PF_HELLO("")
	return CFPropertyListIsValid( (CFPropertyListRef)plist, format );
}

/*
 *	This version only creates XML property lists
 *
 *	CFIndex CFPropertyListWriteToStream (
 *		CFPropertyListRef propertyList,
 *		CFWriteStreamRef stream,
 *		CFPropertyListFormat format,
 *		CFStringRef *errorString );		supports more formats...
 */
+ (NSData *)dataFromPropertyList:(id)plist 
						  format:(NSPropertyListFormat)format 
				errorDescription:(NSString **)errorString
{
	PF_HELLO("")
	
	if( format == NSPropertyListOpenStepFormat )
		return nil; // not supported for writing

	// for now I don't know how to handle binary property lists
	// ACTUALLY... I think I fixed this with a patch to CFLite's CFBinaryPList.c
	//	Someone should really check this...
	//if( format == NSPropertyListBinaryFormat_v1_0 )
	//	return nil; // sorry
	
	NSData *new = (NSData *)CFPropertyListCreateXMLData( kCFAllocatorDefault, (CFPropertyListRef)plist );

	if( (new == nil) || (0 == CFDataGetLength((CFDataRef)new)) )
		return nil; // set error to say something
	
	PF_RETURN_TEMP(new)
}

+ (id)propertyListFromData:(NSData *)data 
		  mutabilityOption:(NSPropertyListMutabilityOptions)opt 
					format:(NSPropertyListFormat *)format 
		  errorDescription:(NSString **)errorString
{
	PF_HELLO("")
	
	//if( format != NULL )
	// not sure how to check the data for what type it is... starting with <xml... stuff?
	
	id plist = (id)CFPropertyListCreateFromXMLData( kCFAllocatorDefault, (CFDataRef)data, opt, (CFStringRef *)errorString );
	PF_RETURN_TEMP(plist)
}

@end
