/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSScanner.m
 *
 *	NSScanner
 *
 *	Created by Stuart Crook on 17/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSScanner.h"
#import "CTScanner.h"

@implementation NSScanner

+(id)alloc
{
	if( self == [NSScanner class] )
		return [CTScanner alloc];
	return [super alloc];
}

/*
 *	Creation methods, which were in NSExtendedScanner
 */
+ (id)scannerWithString:(NSString *)string
{
	return [[[self alloc] initWithString: string] autorelease];
}

+ (id)localizedScannerWithString:(NSString *)string
{
	NSScanner *scanner = [[[self alloc] initWithString: string] autorelease];
	[scanner setLocale: [(id)CFLocaleGetSystem() retain]];
	return scanner;
}

// instance method dummies, to please the compiler
- (NSString *)string { return nil; }
- (NSUInteger)scanLocation { return 0; }
- (void)setScanLocation:(NSUInteger)pos {}
- (void)setCharactersToBeSkipped:(NSCharacterSet *)set {}
- (void)setCaseSensitive:(BOOL)flag {}
- (void)setLocale:(id)locale {}

- (id)copyWithZone:(NSZone *)zone { return nil; }

@end

/*
@interface NSScanner (NSExtendedScanner)

- (NSCharacterSet *)charactersToBeSkipped;
- (BOOL)caseSensitive;
- (id)locale;

- (BOOL)scanInt:(int *)value;
#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED
- (BOOL)scanInteger:(NSInteger *)value;
- (BOOL)scanHexLongLong:(unsigned long long *)result;
- (BOOL)scanHexFloat:(float *)result;		// Corresponding to %a or %A formatting. Requires "0x" or "0X" prefix. 
- (BOOL)scanHexDouble:(double *)result;		// Corresponding to %a or %A formatting. Requires "0x" or "0X" prefix. 
#endif
- (BOOL)scanHexInt:(unsigned *)value;		// Optionally prefixed with "0x" or "0X"
- (BOOL)scanLongLong:(long long *)value;
- (BOOL)scanFloat:(float *)value;
- (BOOL)scanDouble:(double *)value;

- (BOOL)scanString:(NSString *)string intoString:(NSString **)value;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;

- (BOOL)scanUpToString:(NSString *)string intoString:(NSString **)value;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;

- (BOOL)isAtEnd;

- (id)initWithString:(NSString *)string;

@end
*/
