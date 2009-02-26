/*
 *	This file was NSScanner/NSScanner_concrete.h in Cocotron.
 */

	/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
 
	 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
	 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - David Young <daver@geeks.org>
#import "CTScanner.h"
#import "NSString.h"
#import "NSDictionary.h"
#import "NSLocale.h"
#import "NSCharacterSet.h"
//#import <Foundation/NSRaise.h>

/*
 *	This class has been optomised for working on NSCFStrings. If it becomes a problem
 *	then we can resurrect a version which works on generic NSString objects.
 */

@implementation CTScanner

-initWithString:(NSString *)string
{
	_string = (CFStringRef)[string retain];
	
	_location = 0;
	_skipSet = CFCharacterSetGetPredefined( kCFCharacterSetWhitespace );
	_locale = nil;
	_isCaseSensitive = YES;
	//_localeIsDict = NO;

	return self;
}

-(void)dealloc {
	[(id)_string release];
	[(id)_skipSet release];
	[_locale release];
	[super dealloc];
}

-(NSString *)string {
    return (NSString *)_string;
}

-(void)setCharactersToBeSkipped:(NSCharacterSet *)set {
    [(id)_skipSet release];
    _skipSet = (CFCharacterSetRef)[set retain];
}

-(NSCharacterSet *)charactersToBeSkipped {
    return (NSCharacterSet *)_skipSet;
}

-(void)setCaseSensitive:(BOOL)flag {
    _isCaseSensitive = flag;
}
-(BOOL)caseSensitive {
    return _isCaseSensitive;
}

-(void)setLocale:(NSDictionary *)locale {
    [_locale release];
    _locale = [locale retain];
}

-(id)locale {
    return _locale;
}


-(unsigned)scanLocation {
    return _location;
}

-(void)setScanLocation:(unsigned)pos {
	_location=pos;
}


-(BOOL)isAtEnd {
    return _location == CFStringGetLength(_string);
}




-(BOOL)scanInt:(int *)valuep {
    enum {
        STATE_SPACE,
        STATE_DIGITS_ONLY
    } state=STATE_SPACE;
    int sign=1;
    int value=0;
    BOOL hasValue=NO;
	
	// set up the inline buffer
	NSUInteger length = CFStringGetLength(_string);
	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
    for(;_location < length; _location++){
        unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location);
		
        switch(state){
            case STATE_SPACE:
                if( CFCharacterSetIsCharacterMember(_skipSet, unicode) )
                    state=STATE_SPACE;
                else if(unicode=='-'){
                    sign=-1;
                    state=STATE_DIGITS_ONLY;
                }
				else if(unicode>='0' && unicode<='9'){
					value=(value*10)+unicode-'0';
					state=STATE_DIGITS_ONLY;
					hasValue=YES;
				}
				else
					return NO;
                break;
				
            case STATE_DIGITS_ONLY:
                if(unicode>='0' && unicode<='9'){
                    value=(value*10)+unicode-'0';
                    hasValue=YES;
                }
                else if(!hasValue)
                    return NO;
                else {
                    *valuep=sign*value;
                    return YES;
                }
				break;
        }
    }
	
    if(!hasValue)
        return NO;
    else {
        *valuep=sign*value;
        return YES;
    }
}

-(BOOL)scanLongLong:(long long *)valuep {
    enum {
        STATE_SPACE,
        STATE_DIGITS_ONLY
    } state=STATE_SPACE;
    int sign=1;
    long long value=0;
    BOOL hasValue=NO;
	
	// set up the inline buffer
	NSUInteger length = CFStringGetLength(_string);
	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
    for(; _location < length; _location++){
        unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location);
		
        switch(state){
            case STATE_SPACE:
                if( CFCharacterSetIsCharacterMember(_skipSet, unicode) )
                    state=STATE_SPACE;
                else if(unicode=='-'){
                    sign=-1;
                    state=STATE_DIGITS_ONLY;
                }
                else if(unicode>='0' && unicode<='9'){
                    value=(value*10)+unicode-'0';
                    state=STATE_DIGITS_ONLY;
                    hasValue=YES;
                }
                else
                    return NO;
                break;
				
            case STATE_DIGITS_ONLY:
                if(unicode>='0' && unicode<='9'){
                    value=(value*10)+unicode-'0';
                    hasValue=YES;
                }
                else if(!hasValue)
                    return NO;
                else {
                    *valuep=sign*value;
                    return YES;
                }
                break;
        }
    }
	
    if(!hasValue)
        return NO;
    else {
        *valuep=sign*value;
        return YES;
    }
}

-(BOOL)scanFloat:(float *)valuep {
    double d;
    BOOL r;
	
	NSLog(@"scanFloat:");
	
    r = [self scanDouble:&d];
    *valuep = (float)d;
    return r;
}

// "...returns HUGE_VAL or -HUGE_VAL on overflow, 0.0 on underflow." hmm...
-(BOOL)scanDouble:(double *)valuep {
	NSString *seperatorString;
	unichar decimalSeperator;
	
	if(_locale)
		seperatorString = [_locale objectForKey:NSLocaleDecimalSeparator];
	else
		seperatorString = [[NSLocale systemLocale] objectForKey: NSLocaleDecimalSeparator];

	decimalSeperator = ([seperatorString length] > 0 ) ? [seperatorString characterAtIndex:0] : '.';

		// start setting up the inline buffer...
		NSUInteger length = CFStringGetLength(_string);
		
	int     i;
	int     len = length - _location;
	char    p[len + 1], *q;
	unichar c;

		// ...finish setting up the inline buffer
		CFRange range = CFRangeMake(_location, len); // only buffers the portion we're interested in
		CFStringInlineBuffer buffer;
		CFStringInitInlineBuffer(_string, &buffer, range);
	
	for (i = 0; i < len; i++)
	{
		c  =  CFStringGetCharacterFromInlineBuffer(&buffer, i);  //[_string characterAtIndex:i + _location];    
		if (c == decimalSeperator) c = '.';
		p[i] = (char)c;
	}
	p[i] = '\0';
	
	*valuep = strtod(p, &q);
	_location += (q - p);
	return (q > p);
	
	/*
	 enum {
	 STATE_SPACE,
	 STATE_DIGITS_ONLY
	 } state=STATE_SPACE;
	 int sign=1;
	 double value=1.0;
	 BOOL hasValue=NO;
	 
	 for(;_location<[_string length];_location++){
	 unichar unicode=[_string characterAtIndex:_location];
	 
	 switch(state){
	 case STATE_SPACE:
	 if([_skipSet characterIsMember:unicode])
	 state=STATE_SPACE;
	 else if(unicode=='-') {
	 sign=-1;
	 state=STATE_DIGITS_ONLY;
	 }
	 else if(unicode=='+'){
	 sign=1;
	 state=STATE_DIGITS_ONLY;
	 }
	 else if(unicode>='0' && unicode<='9'){
	 value=(value*10)+unicode-'0';
	 state=STATE_DIGITS_ONLY;
	 hasValue=YES;
	 }
	 else if(unicode==decimalSeperator) {
	 double multiplier=1;
	 
	 _location++;
	 for(;_location<[_string length];_location++){
	 if(unicode<'0' || unicode>'9')
	 break;
	 
	 multiplier/=10.0;
	 value+=(unicode-'0')*multiplier;
	 }
	 }
	 else
	 return NO;
	 break;
	 
	 case STATE_DIGITS_ONLY:
	 if(unicode>='0' && unicode<='9'){
	 value=(value*10)+unicode-'0';
	 hasValue=YES;
	 }
	 else if(!hasValue)
	 return NO;
	 else if(unicode==decimalSeperator) {
	 double multiplier=1;
	 
	 _location++;
	 for(;_location<[_string length];_location++){
	 if(unicode<'0' || unicode>'9')
	 break;
	 
	 multiplier/=10.0;
	 value+=(unicode-'0')*multiplier;
	 }
	 }
	 else {
	 *valuep=sign*value;
	 return YES;
	 }
	 break;
	 }
	 }
	 
	 if(!hasValue)
	 return NO;
	 else {
	 *valuep=sign*value;
	 return YES;
	 }
	 */
}

-(BOOL)scanDecimal:(NSDecimal *)valuep {
    NSUnimplementedMethod();
    return NO;
}

-(BOOL)scanInteger:(NSInteger *)valuep {
    NSUnimplementedMethod();
    return NO;
}

// The documentation appears to be wrong, it returns -1 on overflow.
-(BOOL)scanHexInt:(unsigned *)valuep {
	enum {
		STATE_SPACE,
		STATE_ZERO,
		STATE_HEX,
	} state=STATE_SPACE;
	unsigned value=0;
	BOOL     hasValue=NO;
	BOOL     overflow=NO;
	
	// set up the buffer
	NSUInteger length = CFStringGetLength(_string);
	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
	for(; _location < length; _location++) {
		unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location); //[_string characterAtIndex:_location];
		
		switch(state){
				
			case STATE_SPACE:
				if( CFCharacterSetIsCharacterMember(_skipSet, unicode) )
					state=STATE_SPACE;
				else if(unicode == '0'){
					state=STATE_ZERO;
					hasValue=YES;
				}
				else if(unicode>='1' && unicode<='9'){
					value=value*16+(unicode-'0');
					state=STATE_HEX;
					hasValue=YES;
				}
				else if(unicode>='a' && unicode<='f'){
					value=value*16+(unicode-'a')+10;
					state=STATE_HEX;
					hasValue=YES;
				}
				else if(unicode>='A' && unicode<='F'){
					value=value*16+(unicode-'A')+10;
					state=STATE_HEX;
					hasValue=YES;
				}
				else
					return NO;
				break;
				
			case STATE_ZERO:
				state=STATE_HEX;
				if(unicode=='x' || unicode=='X')
					break;
				// fallthrough
			case STATE_HEX:
				if(unicode>='0' && unicode<='9'){
					if(!overflow){
						unsigned check=value*16+(unicode-'0');
						if(check>=value)
							value=check;
						else {
							value=-1;
							overflow=YES;
						}
					}
				}
				else if(unicode>='a' && unicode<='f'){
					if(!overflow){
						unsigned check=value*16+(unicode-'a')+10;
						if(check>=value)
							value=check;
						else {
							value=-1;
							overflow=YES;
						}
					}
				}
				else if(unicode>='A' && unicode<='F'){
					if(!overflow){
						unsigned check=value*16+(unicode-'A')+10;
						
						if(check>=value)
							value=check;
						else {
							value=-1;
							overflow=YES;
						}
					}
				}
				else {
					if(valuep!=NULL)
						*valuep=value;
					
					return YES;
				}
				break;
		}
	}
	
	if(hasValue){
		if(valuep!=NULL)
			*valuep=value;
		
		return YES;
	}
    
	return NO;
}


-(BOOL)scanString:(NSString *)string intoString:(NSString **)stringp 
{
	NSLog(@"scanString:intoString:");
    
	NSUInteger length = CFStringGetLength(_string);
	
	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
    for(;_location<length;_location++) {
        unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location);
		
		// replacing: 
		//		if ([[_string substringFromIndex:_location] hasPrefix:string]) {
		//	This has a longer set-up but should run faster. Check a sub-range rather than
		//	building a sub-string, and then checks whether the found string occured at the
		//	begining of that sub-range
		
		range.location = _location;
		range.length = length-_location;
		
		if( CFStringFindWithOptions(_string, (CFStringRef)string, range, 0, &range) && (range.location == _location) )
		{
            if (stringp != NULL)
                *stringp = string;
			
            _location += [string length];
            return YES;
        }
        else if (!CFCharacterSetIsCharacterMember(_skipSet, unicode))
            return NO;
    }
	
    return NO;
}

-(BOOL)scanUpToString:(NSString *)string intoString:(NSString **)stringp {
    NSUInteger length = CFStringGetLength(_string);

    unichar result[length];
    int resultLength = 0;
    BOOL scanStarted = NO;

	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
    for(;_location<length;_location++) {
        unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location);

        // see above. if ([[_string substringFromIndex:_location] hasPrefix:string]) {
		
		range.location = _location;
		range.length = length-_location;
		
		if( CFStringFindWithOptions(_string, (CFStringRef)string, range, 0, &range) && (range.location == _location) )
		{
            if (stringp != NULL)
                *stringp = [NSString stringWithCharacters:result length:resultLength];
			
            return YES;
        }
        else if (CFCharacterSetIsCharacterMember(_skipSet, unicode) && scanStarted == NO)
            ;
        else {
            scanStarted = YES;
            result[resultLength++] = unicode;
        }
    }
	
    if (resultLength > 0) {
        if (stringp != NULL)
            *stringp = (NSString *)CFStringCreateWithCharacters(kCFAllocatorDefault, (const UniChar*)result, resultLength);
			//[NSString stringWithCharacters:result length:resultLength];
		
        return YES;
    }
    else
        return NO;
}

// assumes charset is a NSCFCharacterSet
-(BOOL)scanCharactersFromSet:(NSCharacterSet *)charset intoString:(NSString **)stringp
{
    NSUInteger length = CFStringGetLength(_string);
	
    unichar result[length];
    int resultLength = 0;
    BOOL scanStarted = NO;
	
	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
    for(;_location<length;_location++)
	{
		unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location);
		
		if (CFCharacterSetIsCharacterMember(_skipSet, unicode) && (scanStarted == NO))
		{
			// do nothing
		}
		else
		{
			if (CFCharacterSetIsCharacterMember((CFCharacterSetRef)charset, unicode))
			{
				scanStarted = YES;
				result[resultLength++] = unicode;
			}
			else
			{
				break; // used to be "return NO";
			}
		}
	}
	
    if (scanStarted)
	{
		if (stringp != NULL)
		{
			*stringp = (NSString *)CFStringCreateWithCharacters(kCFAllocatorDefault, (const UniChar *)result, resultLength);
		}
	}
	return scanStarted;
}

// this now assumes that charset is infact an NSCFCharaterSet object
-(BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)charset intoString:(NSString **)stringp {
    int length = CFStringGetLength(_string);
	
    unichar result[length];
    int resultLength = 0;
    BOOL scanStarted = NO;
	
	CFRange range = CFRangeMake(0, length);
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer(_string, &buffer, range);
	
    for(;_location<length;_location++) {
        unichar unicode = CFStringGetCharacterFromInlineBuffer(&buffer, _location);
		
        if (CFCharacterSetIsCharacterMember((CFCharacterSetRef)charset, unicode))
            break;
        else if (CFCharacterSetIsCharacterMember(_skipSet, unicode) && scanStarted == NO)
            ;
        else {
            scanStarted = YES;
            result[resultLength++] = unicode;
        }
    }
	
    if (resultLength > 0) {
        if (stringp != NULL)
            *stringp = (NSString *)CFStringCreateWithCharacters(kCFAllocatorDefault, (const UniChar *)result, resultLength);
		
        return YES;
    }
    else
        return NO;
}

@end
