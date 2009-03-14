/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSFormatter.m
 *
 *	NSFormatter
 *
 *  Created by Stuart Crook on 14/03/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	NSFormatter is an abstract super-class, which means we don't have to do much in here.
 */
@implementation NSFormatter //: NSObject <NSCopying, NSCoding>

- (NSString *)stringForObjectValue:(id)obj { return nil; }

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs { return nil; }

- (NSString *)editingStringForObjectValue:(id)obj { return nil; }

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { return NO; }

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error { return NO; }
// Compatibility method.  If a subclass overrides this and does not override the new method below, this will be called as before (the new method just calls this one by default).  The selection range will always be set to the end of the text with this method if replacement occurs.

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error { return NO; }

- (id)copyWithZone:(NSZone *)zone { return self; }

@end

