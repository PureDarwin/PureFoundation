/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSNumberFormatter.m
 *
 *	NSNumberFormatter
 *
 *  Created by Stuart Crook on 14/03/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSNumberFormatter.h"
#import "PureFoundation.h"

static NSNumberFormatterBehavior _defaultNumberFormatterBehaviour = NSNumberFormatterBehavior10_4;

/*
 *	Basic outline. I haven't got any further because I need to decide when the wrapped
 *	CFNumberFormatter should be created. Locale and style are fixed when the CFNF is
 *	created, but can be set after the NSNumberFormatter is instantated...
 */

/*
 *	ivars:	NSMutableDictionary	*_attributes;
 *			CFNumberFormatterRef _formatter;
 *			NSUInteger _counter;
 *			void *_reserved[12];
 */
@implementation NSNumberFormatter //: NSObject <NSCopying, NSCoding>

+ (NSNumberFormatterBehavior)defaultFormatterBehavior { return _defaultNumberFormatterBehaviour; }
+ (void)setDefaultFormatterBehavior:(NSNumberFormatterBehavior)behavior { _defaultNumberFormatterBehaviour = behavior; }

- (id)init
{
	if( self = [super init] )
	{
		_attributes = (NSMutableDictionary *)CFDictionaryCreateMutable( kCFAllocatorDefault, 0, (CFDictionaryKeyCallBacks *)&_PFCollectionCallBacks, (CFDictionaryValueCallBacks *)&_PFCollectionCallBacks );
		_formatter = NULL;
		_counter = 0;
	}
	return self;
}

- (NSString *)stringForObjectValue:(id)obj { return nil; }

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs { return nil; }

- (NSString *)editingStringForObjectValue:(id)obj { return nil; }

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { return NO; }

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error { return NO; }
// Compatibility method.  If a subclass overrides this and does not override the new method below, this will be called as before (the new method just calls this one by default).  The selection range will always be set to the end of the text with this method if replacement occurs.

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error { return NO; }

- (id)copyWithZone:(NSZone *)zone { return self; }


//#if MAC_OS_X_VERSION_10_4 <= MAC_OS_X_VERSION_MAX_ALLOWED

// Report the used range of the string and an NSError, in addition to the usual stuff from NSFormatter

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string range:(inout NSRange *)rangep error:(out NSError **)error {}

// Even though NSNumberFormatter responds to the usual NSFormatter methods,
//   here are some convenience methods which are a little more obvious.

- (NSString *)stringFromNumber:(NSNumber *)number {}
- (NSNumber *)numberFromString:(NSString *)string {}

- (NSNumberFormatterStyle)numberStyle {}
- (void)setNumberStyle:(NSNumberFormatterStyle)style {}

- (NSLocale *)locale {}
- (void)setLocale:(NSLocale *)locale {}

- (BOOL)generatesDecimalNumbers {}
- (void)setGeneratesDecimalNumbers:(BOOL)b {}

- (NSNumberFormatterBehavior)formatterBehavior {}
- (void)setFormatterBehavior:(NSNumberFormatterBehavior)behavior {}




- (NSString *)negativeFormat 
{}

- (void)setNegativeFormat:(NSString *)format {}

- (NSDictionary *)textAttributesForNegativeValues {}
- (void)setTextAttributesForNegativeValues:(NSDictionary *)newAttributes {}

- (NSString *)positiveFormat {}
- (void)setPositiveFormat:(NSString *)format {}

- (NSDictionary *)textAttributesForPositiveValues {}
- (void)setTextAttributesForPositiveValues:(NSDictionary *)newAttributes {}

- (BOOL)allowsFloats {}
- (void)setAllowsFloats:(BOOL)flag {}

- (NSString *)decimalSeparator {}
- (void)setDecimalSeparator:(NSString *)string {}

- (BOOL)alwaysShowsDecimalSeparator {}
- (void)setAlwaysShowsDecimalSeparator:(BOOL)b {}

- (NSString *)currencyDecimalSeparator {}
- (void)setCurrencyDecimalSeparator:(NSString *)string {}

- (BOOL)usesGroupingSeparator {}
- (void)setUsesGroupingSeparator:(BOOL)b {}

- (NSString *)groupingSeparator {}
- (void)setGroupingSeparator:(NSString *)string {}


- (NSString *)zeroSymbol {}
- (void)setZeroSymbol:(NSString *)string {}

- (NSDictionary *)textAttributesForZero {}
- (void)setTextAttributesForZero:(NSDictionary *)newAttributes {}

- (NSString *)nilSymbol {}
- (void)setNilSymbol:(NSString *)string {}

- (NSDictionary *)textAttributesForNil {}
- (void)setTextAttributesForNil:(NSDictionary *)newAttributes {}

- (NSString *)notANumberSymbol {}
- (void)setNotANumberSymbol:(NSString *)string {}

- (NSDictionary *)textAttributesForNotANumber {}
- (void)setTextAttributesForNotANumber:(NSDictionary *)newAttributes {}

- (NSString *)positiveInfinitySymbol {}
- (void)setPositiveInfinitySymbol:(NSString *)string {}

- (NSDictionary *)textAttributesForPositiveInfinity {}
- (void)setTextAttributesForPositiveInfinity:(NSDictionary *)newAttributes {}

- (NSString *)negativeInfinitySymbol {}
- (void)setNegativeInfinitySymbol:(NSString *)string {}

- (NSDictionary *)textAttributesForNegativeInfinity {}
- (void)setTextAttributesForNegativeInfinity:(NSDictionary *)newAttributes {}


- (NSString *)positivePrefix {}
- (void)setPositivePrefix:(NSString *)string {}

- (NSString *)positiveSuffix {}
- (void)setPositiveSuffix:(NSString *)string {}

- (NSString *)negativePrefix {}
- (void)setNegativePrefix:(NSString *)string {}

- (NSString *)negativeSuffix {}
- (void)setNegativeSuffix:(NSString *)string {}

- (NSString *)currencyCode {}
- (void)setCurrencyCode:(NSString *)string {}

- (NSString *)currencySymbol {}
- (void)setCurrencySymbol:(NSString *)string {}

- (NSString *)internationalCurrencySymbol {}
- (void)setInternationalCurrencySymbol:(NSString *)string {}

- (NSString *)percentSymbol {}
- (void)setPercentSymbol:(NSString *)string {}

- (NSString *)perMillSymbol {}
- (void)setPerMillSymbol:(NSString *)string {}

- (NSString *)minusSign {}
- (void)setMinusSign:(NSString *)string {}

- (NSString *)plusSign {}
- (void)setPlusSign:(NSString *)string {}

- (NSString *)exponentSymbol {}
- (void)setExponentSymbol:(NSString *)string {}


- (NSUInteger)groupingSize {}
- (void)setGroupingSize:(NSUInteger)number {}

- (NSUInteger)secondaryGroupingSize {}
- (void)setSecondaryGroupingSize:(NSUInteger)number {}

- (NSNumber *)multiplier {}
- (void)setMultiplier:(NSNumber *)number {}

- (NSUInteger)formatWidth {}
- (void)setFormatWidth:(NSUInteger)number {}

- (NSString *)paddingCharacter {}
- (void)setPaddingCharacter:(NSString *)string {}

- (NSNumberFormatterPadPosition)paddingPosition {}
- (void)setPaddingPosition:(NSNumberFormatterPadPosition)position {}

- (NSNumberFormatterRoundingMode)roundingMode {}
- (void)setRoundingMode:(NSNumberFormatterRoundingMode)mode {}

- (NSNumber *)roundingIncrement {}
- (void)setRoundingIncrement:(NSNumber *)number {}

- (NSUInteger)minimumIntegerDigits {}
- (void)setMinimumIntegerDigits:(NSUInteger)number {}

- (NSUInteger)maximumIntegerDigits {}
- (void)setMaximumIntegerDigits:(NSUInteger)number {}

- (NSUInteger)minimumFractionDigits {}
- (void)setMinimumFractionDigits:(NSUInteger)number {}

- (NSUInteger)maximumFractionDigits {}
- (void)setMaximumFractionDigits:(NSUInteger)number {}


- (NSNumber *)minimum {}
- (void)setMinimum:(NSNumber *)number {}

- (NSNumber *)maximum {}
- (void)setMaximum:(NSNumber *)number {}

// these are all AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
- (NSString *)currencyGroupingSeparator {}
- (void)setCurrencyGroupingSeparator:(NSString *)string {}

- (BOOL)isLenient {}
- (void)setLenient:(BOOL)b {}

- (BOOL)usesSignificantDigits {}
- (void)setUsesSignificantDigits:(BOOL)b {}

- (NSUInteger)minimumSignificantDigits {}
- (void)setMinimumSignificantDigits:(NSUInteger)number {}

- (NSUInteger)maximumSignificantDigits {}
- (void)setMaximumSignificantDigits:(NSUInteger)number {}

- (BOOL)isPartialStringValidationEnabled {}
- (void)setPartialStringValidationEnabled:(BOOL)b {}

@end


@implementation NSNumberFormatter (NSNumberFormatterCompatibility)

- (BOOL)hasThousandSeparators {}
- (void)setHasThousandSeparators:(BOOL)flag {}
- (NSString *)thousandSeparator {}
- (void)setThousandSeparator:(NSString *)newSeparator {}

- (BOOL)localizesFormat {}
- (void)setLocalizesFormat:(BOOL)flag {}

- (NSString *)format {}
- (void)setFormat:(NSString *)string {}

- (NSAttributedString *)attributedStringForZero {}
- (void)setAttributedStringForZero:(NSAttributedString *)newAttributedString {}
- (NSAttributedString *)attributedStringForNil {}
- (void)setAttributedStringForNil:(NSAttributedString *)newAttributedString {}
- (NSAttributedString *)attributedStringForNotANumber {}
- (void)setAttributedStringForNotANumber:(NSAttributedString *)newAttributedString {}

- (NSDecimalNumberHandler *)roundingBehavior {}
- (void)setRoundingBehavior:(NSDecimalNumberHandler *)newRoundingBehavior {}

- (NSDecimalNumber *)minimum {}
- (void)setMinimum:(NSDecimalNumber *)aMinimum {}
- (NSDecimalNumber *)maximum {}
- (void)setMaximum:(NSDecimalNumber *)aMaximum {}

@end
