/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSString.m
 *
 *	NSString, NSMutableString and NSCFString
 *
 *	Created by Stuart Crook on 10/03/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSURL.h"

@implementation NSString (NSURLUtilities)

/* Adds all percent escapes necessary to convert the receiver in to a legal URL string.  Uses the given encoding to determine the correct percent escapes (returning nil if the given encoding cannot encode a particular character).  See CFURLCreateStringByAddingPercentEscapes in CFURL.h for more complex transformations */
- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc
{
	CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(enc);
	if( encoding == kCFStringEncodingInvalidId ) encoding = kCFStringEncodingUTF8;
	
	CFStringRef string = CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)self, NULL, NULL, encoding);
	PF_RETURN_TEMP(string)
}

/* Replaces all percent escapes with the matching characters as determined by the given encoding.  Returns nil if the transformation is not possible (i.e. the percent escapes give a byte sequence not legal in the given encoding).  See CFURLCreateStringByReplacingPercentEscapes in CFURL.h for more complex transformations */
- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc
{
	CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(enc);
	if( encoding == kCFStringEncodingInvalidId ) encoding = kCFStringEncodingUTF8;
	
	CFStringRef string = CFURLCreateStringByReplacingPercentEscapesUsingEncoding( kCFAllocatorDefault, (CFStringRef)self, NULL, encoding );
	PF_RETURN_TEMP(string)
}

@end
