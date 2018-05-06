/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSCharacterSet.m
 *
 *	NSCharacterSet, NSMutableCharacterSet, NSCFCharacterSet
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSCharacterSet.h"
//#import "../CF-476.15.patched/CFCharacterSet.h"

/*
 *	The bridged class
 */
@interface __NSCFCharacterSet : NSMutableCharacterSet
@end

/*
 *	The dummy variables
 */
static Class _PFNSCFCharacterSetClass = nil;
static Class _PFNSCFMutableCharacterSetClass = nil;

/*
 *	The mutability-checking macros
 */
extern bool _CFCharacterSetIsMutable( CFCharacterSetRef cset );

#define PF_CHECK_CSET(cset) BOOL isMutable; \
	if( cset == (id)&_PFNSCFCharacterSetClass ) isMutable = NO; \
	else if( cset == (id)&_PFNSCFMutableCharacterSetClass ) isMutable = YES; \
	else { isMutable = _CFCharacterSetIsMutable((CFCharacterSetRef)cset); [cset autorelease]; }

#define PF_RETURN_CSET_INIT if( isMutable == YES ) { [self autorelease]; self = (id)CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, (CFCharacterSetRef)self ); } \
	PF_RETURN_NEW(self)

#define PF_CHECK_CSET_MUTABLE(cset) if( !_CFCharacterSetIsMutable((CFCharacterSetRef)cset) ) \
	[NSException raise: NSInternalInconsistencyException format: [NSString stringWithCString: "Attempting mutable character set op on a static NSCharacterSet" encoding: NSUTF8StringEncoding]];


/*
 *	A chatagory declaring the hidden init methods, which are declard on NSCharacterSet
 *	in order to supress compiler warnings...
 */
// we'll try over-riding both sets of class creation methods
//@interface NSCharacterSet (PFCharacterSetCreation)
//- (id)_characterSetWithRange:(NSRange)aRange;
//- (id)_characterSetWithCharactersInString:(NSString *)aString;
//- (id)_characterSetWithBitmapRepresentation:(NSData *)data;
//- (id)_characterSetWithContentsOfFile:(NSString *)fName;
//@end


/*
 *	NSCharacterSet
 */
@implementation NSCharacterSet

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSCharacterSet class] )
		_PFNSCFCharacterSetClass = objc_getClass("NSCFCharacterSet");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSCharacterSet class] )
		return (id)&_PFNSCFCharacterSetClass;
	return [super alloc];
}

/**	NSCopying COMPLIANCE **/

/*
 *	Return nil, because NSString should never be instatitated
 */
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

/** NSMutableCopying COMPLIANCE **/

/*
 *	Create an NSCFMutableString
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return nil;
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

/*
 *	CharacterSet class creation methods
 *
 *	These call into the specific hidden NSCFCharacterSet instance creation methods, because character 
 *	sets don't support alloc-init creation, aparently
 */
+ (id)characterSetWithRange:(NSRange)aRange 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithRange: aRange] autorelease];
	CFRange theRange = CFRangeMake( aRange.location, aRange.length );
	CFCharacterSetRef set = CFCharacterSetCreateWithCharactersInRange( kCFAllocatorDefault, theRange );
	PF_RETURN_TEMP(set)
}

+ (id)characterSetWithCharactersInString:(NSString *)aString 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithCharactersInString: aString] autorelease];
	CFCharacterSetRef set = CFCharacterSetCreateWithCharactersInString( kCFAllocatorDefault, (CFStringRef)aString );
	PF_RETURN_TEMP(set)
}

+ (id)characterSetWithBitmapRepresentation:(NSData *)data 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithBitmapRepresentation: data] autorelease];
	CFCharacterSetRef set = CFCharacterSetCreateWithBitmapRepresentation( kCFAllocatorDefault, (CFDataRef)data );
	PF_RETURN_TEMP(set)
}

+ (id)characterSetWithContentsOfFile:(NSString *)fName 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithContentsOfFile: fName] autorelease];
	NSData *data = [NSData dataWithContentsOfFile: fName]; // has been autoreleased
	if( data == nil ) return nil;
	CFCharacterSetRef set = CFCharacterSetCreateWithBitmapRepresentation( kCFAllocatorDefault, (CFDataRef)data );
	PF_RETURN_TEMP(set)
}

// instance method declarations to shut the compiler up about the above
//- (id)_characterSetWithRange:(NSRange)aRange { return nil; }
//- (id)_characterSetWithCharactersInString:(NSString *)aString { return nil; }
//- (id)_characterSetWithBitmapRepresentation:(NSData *)data { return nil; }
//- (id)_characterSetWithContentsOfFile:(NSString *)fName { return nil; }

/*
 *	Constant character sets
 */
+ (id)controlCharacterSet 
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetControl );
}

+ (id)whitespaceCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetWhitespace );
}

+ (id)whitespaceAndNewlineCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetWhitespaceAndNewline );
}

+ (id)decimalDigitCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetDecimalDigit );
}

+ (id)letterCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetLetter );
}

+ (id)lowercaseLetterCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetLowercaseLetter );
}

+ (id)uppercaseLetterCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetUppercaseLetter );
}

+ (id)nonBaseCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetNonBase );
}

+ (id)alphanumericCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetAlphaNumeric );
}

+ (id)decomposableCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetDecomposable );
}

+ (id)illegalCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetIllegal );
}

+ (id)punctuationCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetPunctuation );
}

+ (id)capitalizedLetterCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetCapitalizedLetter );
}

+ (id)symbolCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetSymbol );
}

+ (id)newlineCharacterSet
{
	PF_HELLO("")
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetNewline );
}



/*
 *	Instance class methods, for the compiler
 */
- (BOOL)characterIsMember:(unichar)aCharacter { return NO; }
- (NSData *)bitmapRepresentation { return nil; }
- (NSCharacterSet *)invertedSet { return nil; }
- (BOOL)longCharacterIsMember:(UTF32Char)theLongChar { return NO; }
- (BOOL)isSupersetOfSet:(NSCharacterSet *)theOtherSet { return NO; }
- (BOOL)hasMemberInPlane:(uint8_t)thePlane { return NO; }

@end




/*
 *	NSMutableCharacterSet
 */
@implementation NSMutableCharacterSet

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSCharacterSet class] )
		_PFNSCFMutableCharacterSetClass = objc_getClass("NSCFCharacterSet");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSCharacterSet class] )
		return (id)&_PFNSCFMutableCharacterSetClass;
	return [super alloc];
}

// don't need to repeate copying, mutable copying and encoding

+ (id)characterSetWithRange:(NSRange)aRange 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithRange: aRange] autorelease];
	CFRange theRange = CFRangeMake( aRange.location, aRange.length );
	CFCharacterSetRef set = CFCharacterSetCreateWithCharactersInRange( kCFAllocatorDefault, theRange );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	[(id)set release];
	PF_RETURN_TEMP(mset)
}

+ (id)characterSetWithCharactersInString:(NSString *)aString 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithCharactersInString: aString] autorelease];
	CFCharacterSetRef set = CFCharacterSetCreateWithCharactersInString( kCFAllocatorDefault, (CFStringRef)aString );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	[(id)set release];
	PF_RETURN_TEMP(mset)
}

+ (id)characterSetWithBitmapRepresentation:(NSData *)data 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithBitmapRepresentation: data] autorelease];
	CFCharacterSetRef set = CFCharacterSetCreateWithBitmapRepresentation( kCFAllocatorDefault, (CFDataRef)data );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	[(id)set release];
	PF_RETURN_TEMP(mset)
}

+ (id)characterSetWithContentsOfFile:(NSString *)fName 
{
	PF_HELLO("")
	//return [[[self alloc] _characterSetWithContentsOfFile: fName] autorelease];
	NSData *data = [NSData dataWithContentsOfFile: fName]; // has been autoreleased
	if( data == nil ) return nil;
	CFCharacterSetRef set = CFCharacterSetCreateWithBitmapRepresentation( kCFAllocatorDefault, (CFDataRef)data );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	[(id)set release];
	PF_RETURN_TEMP(mset)
}

/*
 *	Tests show that constant character sets returned via NSMutableCharacterSet
 *	should be mutable.
 */
+ (id)controlCharacterSet 
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetControl );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)whitespaceCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetWhitespace );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)whitespaceAndNewlineCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetWhitespaceAndNewline );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)decimalDigitCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetDecimalDigit );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)letterCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetLetter );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)lowercaseLetterCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetLowercaseLetter );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)uppercaseLetterCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetUppercaseLetter );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)nonBaseCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetNonBase );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)alphanumericCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetAlphaNumeric );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)decomposableCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetDecomposable );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)illegalCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetIllegal );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)punctuationCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetPunctuation );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)capitalizedLetterCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetCapitalizedLetter );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)symbolCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetSymbol );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}

+ (id)newlineCharacterSet
{
	PF_HELLO("")
	CFCharacterSetRef set = CFCharacterSetGetPredefined( kCFCharacterSetNewline );
	CFMutableCharacterSetRef mset = CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, set );
	PF_RETURN_TEMP(mset)
}


/*
 *	Mutable-specific instance methods
 */
- (void)addCharactersInRange:(NSRange)aRange {}
- (void)removeCharactersInRange:(NSRange)aRange {}
- (void)addCharactersInString:(NSString *)aString {}
- (void)removeCharactersInString:(NSString *)aString {}
- (void)formUnionWithCharacterSet:(NSCharacterSet *)otherSet {}
- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)otherSet {}
- (void)invert {}

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

/** NSMutableCopying COMPLIANCE **/
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return nil;
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

@end



/*
 *	NSCFCharacterSet, the bridged class
 */
@implementation __NSCFCharacterSet

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFCharacterSetGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

// NSCharacterSet returns the standard NSObject description of itself
//-(NSString *)description
//{
//	// needs to be replaced?
//	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
//}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	PF_HELLO("")
	PF_RETURN_NEW( CFCharacterSetCreateCopy( kCFAllocatorDefault, (CFCharacterSetRef)self ) )
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
	PF_HELLO("")
	PF_RETURN_NEW( CFCharacterSetCreateMutableCopy( kCFAllocatorDefault, (CFCharacterSetRef)self ) )
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
	return nil;
}

////
//////	ADD AN init METHOD ????
///

/*
 *	CharacterSet class creation methods, here re-defines as hidden class instance methods
 *
 *	Although these could just as easily be handled with separate version inside the NSCharacterSet
 *	and NSMutableCharacterSet classes...
 */
//- (id)_characterSetWithRange:(NSRange)aRange 
//{
//	PF_HELLO("")
//	PF_CHECK_CSET(self)
//
//	CFRange theRange = CFRangeMake( aRange.location, aRange.length );
//	
//	self = (id)CFCharacterSetCreateWithCharactersInRange( kCFAllocatorDefault, theRange );
//	
//	PF_RETURN_CSET_INIT
//}

//- (id)_characterSetWithCharactersInString:(NSString *)aString 
//{
//	PF_HELLO("")
//	PF_CHECK_CSET(self)
//
//	self = (id)CFCharacterSetCreateWithCharactersInString( kCFAllocatorDefault, (CFStringRef)aString );
//
//	PF_RETURN_CSET_INIT
//}

//- (id)_characterSetWithBitmapRepresentation:(NSData *)data 
//{
//	PF_HELLO("")
//	PF_CHECK_CSET(self)
//
//	self = (id)CFCharacterSetCreateWithBitmapRepresentation( kCFAllocatorDefault, (CFDataRef)data );
//
//	PF_RETURN_CSET_INIT
//}

//- (id)_characterSetWithContentsOfFile:(NSString *)fName 
//{
//	PF_TODO
//	PF_CHECK_CSET(self)
//
	// file -> CFData, and then createWithBitmap
//	
//	PF_RETURN_CSET_INIT
//}


/*
 *	Instance class methods
 */
- (BOOL)characterIsMember:(unichar)aCharacter 
{ 
	PF_HELLO("")
	return CFCharacterSetIsCharacterMember( (CFCharacterSetRef)self, (UniChar)aCharacter );
}

- (NSData *)bitmapRepresentation 
{ 
	PF_HELLO("")
	CFDataRef data = CFCharacterSetCreateBitmapRepresentation( kCFAllocatorDefault, (CFCharacterSetRef)self );
	PF_RETURN_TEMP(data)
}

- (NSCharacterSet *)invertedSet 
{ 
	PF_HELLO("")
	CFCharacterSetRef cset = CFCharacterSetCreateInvertedSet( kCFAllocatorDefault, (CFCharacterSetRef)self );
	PF_RETURN_TEMP(cset)
}

- (BOOL)longCharacterIsMember:(UTF32Char)theLongChar 
{ 
	PF_HELLO("")
	return CFCharacterSetIsLongCharacterMember( (CFCharacterSetRef)self, theLongChar );
}

- (BOOL)isSupersetOfSet:(NSCharacterSet *)theOtherSet 
{ 
	PF_HELLO("")
	return CFCharacterSetIsSupersetOfSet( (CFCharacterSetRef)self, (CFCharacterSetRef)theOtherSet ); 
}

- (BOOL)hasMemberInPlane:(uint8_t)thePlane 
{ 
	PF_HELLO("")
	return CFCharacterSetHasMemberInPlane( (CFCharacterSetRef)self , (CFIndex)thePlane ); 
}


/*
 *	Mutable-specific instance methods
 */
- (void)addCharactersInRange:(NSRange)aRange 
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	if( aRange.length == 0 ) return;
	CFRange range = CFRangeMake( aRange.location, aRange.length );
	CFCharacterSetAddCharactersInRange( (CFMutableCharacterSetRef)self, range );
}

- (void)removeCharactersInRange:(NSRange)aRange
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	if( aRange.length == 0 ) return;
	CFRange range = CFRangeMake( aRange.location, aRange.length );
	CFCharacterSetRemoveCharactersInRange( (CFMutableCharacterSetRef)self, range );
}

- (void)addCharactersInString:(NSString *)aString
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	if( (aString == nil) || ([aString length] == 0) ) return;
	CFCharacterSetAddCharactersInString( (CFMutableCharacterSetRef)self, (CFStringRef)aString );
}

- (void)removeCharactersInString:(NSString *)aString
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	if( (aString == nil) || ([aString length] == 0) ) return;
	CFCharacterSetRemoveCharactersInString( (CFMutableCharacterSetRef)self, (CFStringRef)aString );
}

- (void)formUnionWithCharacterSet:(NSCharacterSet *)otherSet
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	if( otherSet == nil ) return;
	CFCharacterSetUnion( (CFMutableCharacterSetRef)self, (CFCharacterSetRef)otherSet );
}

- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)otherSet
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	if( otherSet == nil ) return;
	CFCharacterSetIntersect( (CFMutableCharacterSetRef)self, (CFCharacterSetRef)otherSet );
}

- (void)invert
{
	PF_HELLO("")
	PF_CHECK_CSET_MUTABLE(self)
	CFCharacterSetInvert( (CFMutableCharacterSetRef)self );
}

@end
