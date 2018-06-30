/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSRange.m
 *
 *	Various range manipulation functions
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSRange.h"

/*
 *	These implementations come from GNUStep, in the files NSRange.h and NSRange.m
 */

	/* 
	 * Copyright (C) 1995,1999 Free Software Foundation, Inc.
	 * 
	 * Written by:  Adam Fedor <fedor@boulder.colorado.edu>
	 * Date: 1995
	 * 
	 * This file is part of the GNUstep Base Library.
	 * 
	 * This library is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU Lesser General Public
	 * License as published by the Free Software Foundation; either
	 * version 2 of the License, or (at your option) any later version.
	 * 
	 * This library is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 * Library General Public License for more details.
	 * 
	 * You should have received a copy of the GNU Lesser General Public
	 * License along with this library; if not, write to the Free
	 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
	 * Boston, MA 02111 USA.
	 */ 

/** Returns range going from minimum of aRange's and bRange's locations to
 maximum of their two max's. */
NSRange NSUnionRange(NSRange aRange, NSRange bRange)
{
	NSRange range;
	
	range.location = MIN(aRange.location, bRange.location);
	range.length   = MAX(NSMaxRange(aRange), NSMaxRange(bRange)) - range.location;
	return range;
}

/** Returns range containing indices existing in both aRange and bRange.  If
 *  the returned length is 0, the location is undefined and should be ignored.
 */
NSRange NSIntersectionRange (NSRange aRange, NSRange bRange)
{
	NSRange range;
	
	if (NSMaxRange(aRange) < bRange.location
		|| NSMaxRange(bRange) < aRange.location)
		return NSMakeRange(0, 0);
	
	range.location = MAX(aRange.location, bRange.location);
	range.length   = MIN(NSMaxRange(aRange), NSMaxRange(bRange)) - range.location;
	return range;
}

	/** NSRange - range functions
	 * Copyright (C) 1993, 1994, 1995 Free Software Foundation, Inc.
	 *
	 * Written by:  Adam Fedor <fedor@boulder.colorado.edu>
	 * Date: Mar 1995
	 *
	 * This file is part of the GNUstep Base Library.
	 *
	 * This library is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU Lesser General Public
	 * License as published by the Free Software Foundation; either
	 * version 2 of the License, or (at your option) any later version.
	 *
	 * This library is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 * Library General Public License for more details.
	 *
	 * You should have received a copy of the GNU Lesser General Public
	 * License along with this library; if not, write to the Free
	 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
	 * Boston, MA 02111 USA.
 
	 <title>NSRange class reference</title>
	 $Date: 2008-06-09 05:05:01 +0100 (Mon, 09 Jun 2008) $ $Revision: 26607 $
	 */

NSRange NSRangeFromString(NSString *aString)
{
	NSScanner *scanner = [NSScanner scannerWithString: aString];
	NSRange	range;

	SEL scanStringSel = @selector(scanString:intoString:);
	SEL scanIntSel = @selector(scanInt:);
	IMP scanStringImp = [scanner methodForSelector: scanStringSel];
	IMP scanIntImp = [scanner methodForSelector: scanIntSel];
	
	//setupCache();
	if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
		&& (*scanIntImp)(scanner, scanIntSel, (int*)&range.location)
		&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
		&& (*scanIntImp)(scanner, scanIntSel, (int*)&range.length)
		&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
	{
		return range;
	}
	else
	{
		[scanner setScanLocation: 0];
		if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"location", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanIntImp)(scanner, scanIntSel, (int*)&range.location)
			&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"length", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanIntImp)(scanner, scanIntSel, (int*)&range.length)
			&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
		{
			return range;
		}
	}
	
	return NSMakeRange(0, 0);
}

NSString *NSStringFromRange(NSRange range)
{
	//setupCache();
	return [NSString stringWithFormat: @"{%d, %d}", range.location, range.length];
}
