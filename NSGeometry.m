/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSGeometry.m
 *
 *	Various geometry parsing functions
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSGeometry.h"

/*
 *	Constant structs
 */
const NSPoint NSZeroPoint = { 0.0, 0.0 };
const NSSize NSZeroSize = { 0.0, 0.0 };
const NSRect NSZeroRect = { { 0.0, 0.0 }, { 0.0, 0.0 } };


/*
 *	Geometry-examining functions.
 *
 *	These are taken from GNUStep, where they originally appeared in NSGeometry.h 
 *	and NSGeometry.m 
 */

	/* Interface for NSGeometry routines for GNUStep
	 * Copyright (C) 1995 Free Software Foundation, Inc.
	 * 
	 * Written by:  Adam Fedor <fedor@boulder.colorado.edu>
	 * Date: 1995,199
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

/** Returns 'YES' iff the area of aRect is zero (i.e., iff either
 * of aRect's width or height is negative or zero). */
BOOL NSIsEmptyRect(NSRect aRect)
{
	return ((NSWidth(aRect) > 0) && (NSHeight(aRect) > 0)) ? NO : YES;
}

/** Returns the rectangle obtained by translating aRect
 * horizontally by dx and vertically by dy. */
NSRect NSOffsetRect(NSRect aRect, float dx, float dy)
{
	NSRect rect = aRect;
	
	rect.origin.x += dx;
	rect.origin.y += dy;
	return rect;
}

/** Returns the rectangle obtained by moving each of aRect's
 * horizontal sides inward by dy and each of aRect's vertical
 * sides inward by dx. */
NSRect NSInsetRect(NSRect aRect, float dX, float dY)
{
	NSRect rect;
	
	rect = NSOffsetRect(aRect, dX, dY);
	rect.size.width -= (2 * dX);
	rect.size.height -= (2 * dY);
	return rect;
}

/** Returns the smallest rectangle which contains both aRect
 * and bRect (modulo a set of measure zero).  If either of aRect
 * or bRect is an empty rectangle, then the other rectangle is
 * returned.  If both are empty, then the empty rectangle is returned. */
NSRect NSUnionRect(NSRect aRect, NSRect bRect)
{
	NSRect rect;
	
	if (NSIsEmptyRect(aRect) && NSIsEmptyRect(bRect))
		return NSMakeRect(0.0,0.0,0.0,0.0);
	else if (NSIsEmptyRect(aRect))
		return bRect;
	else if (NSIsEmptyRect(bRect))
		return aRect;
	
	rect = NSMakeRect(MIN(NSMinX(aRect), NSMinX(bRect)),
					  MIN(NSMinY(aRect), NSMinY(bRect)), 0.0, 0.0);
	
	rect = NSMakeRect(NSMinX(rect),
					  NSMinY(rect),
					  MAX(NSMaxX(aRect), NSMaxX(bRect)) - NSMinX(rect),
					  MAX(NSMaxY(aRect), NSMaxY(bRect)) - NSMinY(rect));
	
	return rect;
}

/** Returns the largest rectangle which lies in both aRect and
 * bRect.  If aRect and bRect have empty intersection (or, rather,
 * intersection of measure zero, since this includes having their
 * intersection be only a point or a line), then the empty
 * rectangle is returned. */
NSRect NSIntersectionRect (NSRect aRect, NSRect bRect)
{
	if (NSMaxX(aRect) <= NSMinX(bRect) || NSMaxX(bRect) <= NSMinX(aRect)
		|| NSMaxY(aRect) <= NSMinY(bRect) || NSMaxY(bRect) <= NSMinY(aRect)) 
    {
		return NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
	else
    {
		NSRect    rect;
		
		if (NSMinX(aRect) <= NSMinX(bRect))
			rect.origin.x = bRect.origin.x;
		else
			rect.origin.x = aRect.origin.x;
		
		if (NSMinY(aRect) <= NSMinY(bRect))
			rect.origin.y = bRect.origin.y;
		else
			rect.origin.y = aRect.origin.y;
		
		if (NSMaxX(aRect) >= NSMaxX(bRect))
			rect.size.width = NSMaxX(bRect) - rect.origin.x;
		else
			rect.size.width = NSMaxX(aRect) - rect.origin.x;
		
		if (NSMaxY(aRect) >= NSMaxY(bRect))
			rect.size.height = NSMaxY(bRect) - rect.origin.y;
		else
			rect.size.height = NSMaxY(aRect) - rect.origin.y;
		
		return rect;
    }
}

/** Returns 'YES' iff aRect's and bRect's origin and size are the same. */
BOOL NSEqualRects(NSRect aRect, NSRect bRect)
{
	return ((NSMinX(aRect) == NSMinX(bRect))
			&& (NSMinY(aRect) == NSMinY(bRect))
			&& (NSWidth(aRect) == NSWidth(bRect))
			&& (NSHeight(aRect) == NSHeight(bRect))) ? YES : NO;
}

/** Returns 'YES' iff aSize's and bSize's width and height are the same. */
BOOL NSEqualSizes(NSSize aSize, NSSize bSize)
{
	return ((aSize.width == bSize.width)
			&& (aSize.height == bSize.height)) ? YES : NO;
}

/** Returns 'YES' iff aPoint's and bPoint's x- and y-coordinates
 * are the same. */
BOOL NSEqualPoints(NSPoint aPoint, NSPoint bPoint)
{
	return ((aPoint.x == bPoint.x)
			&& (aPoint.y == bPoint.y)) ? YES : NO;
}

/** Returns 'YES' iff aPoint is inside aRect. */ 
BOOL NSMouseInRect(NSPoint aPoint, NSRect aRect, BOOL flipped)
{
	if (flipped)
		return ((aPoint.x >= NSMinX(aRect))
				&& (aPoint.y >= NSMinY(aRect))
				&& (aPoint.x < NSMaxX(aRect))
				&& (aPoint.y < NSMaxY(aRect))) ? YES : NO;
	else
		return ((aPoint.x >= NSMinX(aRect))
				&& (aPoint.y > NSMinY(aRect))
				&& (aPoint.x < NSMaxX(aRect))
				&& (aPoint.y <= NSMaxY(aRect))) ? YES : NO;
}

/** Just like 'NSMouseInRect(aPoint, aRect, YES)'. */
BOOL NSPointInRect(NSPoint aPoint, NSRect aRect)
{
	return NSMouseInRect(aPoint, aRect, YES);
}

/** Returns 'YES' iff aRect totally encloses bRect.  NOTE: For
 * this to be the case, aRect cannot be empty, nor can any side
 * of bRect go beyond any side of aRect. Note that this behavior
 * is different than the original OpenStep behavior, where the sides
 * of bRect could not touch aRect. */
BOOL NSContainsRect(NSRect aRect, NSRect bRect)
{
	return (!NSIsEmptyRect(bRect)
			&& (NSMinX(aRect) <= NSMinX(bRect))
			&& (NSMinY(aRect) <= NSMinY(bRect))
			&& (NSMaxX(aRect) >= NSMaxX(bRect))
			&& (NSMaxY(aRect) >= NSMaxY(bRect))) ? YES : NO;
}

/** Returns YES if aRect and bRect have non-zero intersection area
 (intersecting at a line or a point doesn't count). */
BOOL NSIntersectsRect(NSRect aRect, NSRect bRect)
{
	/* Note that intersecting at a line or a point doesn't count */
	return (NSMaxX(aRect) <= NSMinX(bRect)
			|| NSMaxX(bRect) <= NSMinX(aRect)
			|| NSMaxY(aRect) <= NSMinY(bRect)
			|| NSMaxY(bRect) <= NSMinY(aRect)) ? NO : YES;
}

	/** NSGeometry.m - geometry functions
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
 
	 <title>NSGeometry class reference</title>
	 $Date: 2008-06-09 05:05:01 +0100 (Mon, 09 Jun 2008) $ $Revision: 26607 $
	 */

NSRect NSIntegralRect(NSRect aRect)
{
	NSRect	rect;
	
	if (NSIsEmptyRect(aRect))
		return NSMakeRect(0, 0, 0, 0);
	
	rect.origin.x = floor(NSMinX(aRect));
	rect.origin.y = floor(NSMinY(aRect));
	rect.size.width = ceil(NSMaxX(aRect)) - rect.origin.x;
	rect.size.height = ceil(NSMaxY(aRect)) - rect.origin.y;
	return rect;
}

void NSDivideRect(NSRect aRect, NSRect *slice, NSRect *remainder, float amount, NSRectEdge edge)
{
	static NSRect sRect;
	static NSRect	rRect;
	
	if (!slice)
		slice = &sRect;
	if (!remainder)
		remainder = &rRect;
	
	if (NSIsEmptyRect(aRect))
    {
		*slice = NSMakeRect(0,0,0,0);
		*remainder = NSMakeRect(0,0,0,0);
		return;
    }
	
	switch (edge)
    {
		case NSMinXEdge:
			if (amount > aRect.size.width)
			{
				*slice = aRect;
				*remainder = NSMakeRect(NSMaxX(aRect),
										aRect.origin.y,
										0,
										aRect.size.height);
			}
			else
			{
				*slice = NSMakeRect(aRect.origin.x,
									aRect.origin.y,
									amount,
									aRect.size.height);
				*remainder = NSMakeRect(NSMaxX(*slice),
										aRect.origin.y,
										NSMaxX(aRect) - NSMaxX(*slice),
										aRect.size.height);
			}
			break;
		case NSMinYEdge:
			if (amount > aRect.size.height)
			{
				*slice = aRect;
				*remainder = NSMakeRect(aRect.origin.x,
										NSMaxY(aRect),
										aRect.size.width, 0);
			}
			else
			{
				*slice = NSMakeRect(aRect.origin.x,
									aRect.origin.y,
									aRect.size.width,
									amount);
				*remainder = NSMakeRect(aRect.origin.x,
										NSMaxY(*slice),
										aRect.size.width,
										NSMaxY(aRect) - NSMaxY(*slice));
			}
			break;
		case (NSMaxXEdge):
			if (amount > aRect.size.width)
			{
				*slice = aRect;
				*remainder = NSMakeRect(aRect.origin.x,
										aRect.origin.y,
										0,
										aRect.size.height);
			}
			else
			{
				*slice = NSMakeRect(NSMaxX(aRect) - amount,
									aRect.origin.y,
									amount,
									aRect.size.height);
				*remainder = NSMakeRect(aRect.origin.x,
										aRect.origin.y,
										NSMinX(*slice) - aRect.origin.x,
										aRect.size.height);
			}
			break;
		case NSMaxYEdge:
			if (amount > aRect.size.height)
			{
				*slice = aRect;
				*remainder = NSMakeRect(aRect.origin.x,
										aRect.origin.y,
										aRect.size.width,
										0);
			}
			else
			{
				*slice = NSMakeRect(aRect.origin.x,
									NSMaxY(aRect) - amount,
									aRect.size.width,
									amount);
				*remainder = NSMakeRect(aRect.origin.x,
										aRect.origin.y,
										aRect.size.width,
										NSMinY(*slice) - aRect.origin.y);
			}
			break;
		default:
			break;
    }
	
	return;
}

/** Get a String Representation... **/
/* NOTE: Spaces around '=' so that old OpenStep implementations can
 read our strings (Both GNUstep and Mac OS X can read these as well).  */

NSString* NSStringFromPoint(NSPoint aPoint)
{
	//setupCache();
	//if (GSMacOSXCompatibleGeometry() == YES)
		return [NSString stringWithFormat: @"{%g, %g}", aPoint.x, aPoint.y];
	//else
	//	return [NSStringClass stringWithFormat:
	//			@"{x = %g; y = %g}", aPoint.x, aPoint.y];
}

NSString* NSStringFromRect(NSRect aRect)
{
	//setupCache();
	//if (GSMacOSXCompatibleGeometry() == YES)
		return [NSString stringWithFormat: @"{{%g, %g}, {%g, %g}}", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height];
	//else
	//	return [NSStringClass stringWithFormat:
	//			@"{x = %g; y = %g; width = %g; height = %g}",
	//			aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height];
}

NSString* NSStringFromSize(NSSize aSize)
{
	//setupCache();
	//if (GSMacOSXCompatibleGeometry() == YES)
		return [NSString stringWithFormat: @"{%g, %g}", aSize.width, aSize.height];
	//else
	//	return [NSStringClass stringWithFormat:
	//			@"{width = %g; height = %g}", aSize.width, aSize.height];
}

NSPoint NSPointFromString(NSString* string)
{
	NSScanner *scanner = [NSScanner scannerWithString: string];
	NSPoint	point;

	SEL scanStringSel = @selector(scanString:intoString:);
	SEL scanFloatSel = @selector(scanFloat:);
	IMP scanStringImp = [scanner methodForSelector: scanStringSel];
	IMP scanFloatImp = [scanner methodForSelector: scanFloatSel];

	//setupCache();
	if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
		&& (*scanFloatImp)(scanner, scanFloatSel, &point.x)
		&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
		&& (*scanFloatImp)(scanner, scanFloatSel, &point.y)
		&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
    {
		return point;
    }
	else
    {
		[scanner setScanLocation: 0];
		if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"x", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &point.x)
			&& (*scanStringImp)(scanner, scanStringSel, @";", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"y", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &point.y)
			&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
		{
			return point;
		}
	}
	
	return NSMakePoint(0, 0);
}


NSSize NSSizeFromString(NSString* string)
{
	NSScanner *scanner = [NSScanner scannerWithString: string];
	NSSize	size;
	
	SEL scanStringSel = @selector(scanString:intoString:);
	SEL scanFloatSel = @selector(scanFloat:);
	IMP scanStringImp = [scanner methodForSelector: scanStringSel];
	IMP scanFloatImp = [scanner methodForSelector: scanFloatSel];
	
	//setupCache();
	if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
		&& (*scanFloatImp)(scanner, scanFloatSel, &size.width)
		&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
		&& (*scanFloatImp)(scanner, scanFloatSel, &size.height)
		&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
    {
		return size;
    }
	else
    {
		[scanner setScanLocation: 0];
		if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"width", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &size.width)
			&& (*scanStringImp)(scanner, scanStringSel, @";", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"height", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &size.height)
			&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
		{
			return size;
		}
	}		
	
	return NSMakeSize(0, 0);
}

NSRect NSRectFromString(NSString* string)
{
	NSScanner *scanner = [NSScanner scannerWithString: string];
	NSRect	rect;
	
	SEL scanStringSel = @selector(scanString:intoString:);
	SEL scanFloatSel = @selector(scanFloat:);
	IMP scanStringImp = [scanner methodForSelector: scanStringSel];
	IMP scanFloatImp = [scanner methodForSelector: scanFloatSel];
	
	//setupCache();
	if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
		&& (*scanStringImp)(scanner, scanStringSel, @"{", NULL)
		&& (*scanFloatImp)(scanner, scanFloatSel, &rect.origin.x)
		&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
		
		&& (*scanFloatImp)(scanner, scanFloatSel, &rect.origin.y)
		&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL)
		&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
		
		&& (*scanStringImp)(scanner, scanStringSel, @"{", NULL)
		&& (*scanFloatImp)(scanner, scanFloatSel, &rect.size.width)
		&& (*scanStringImp)(scanner, scanStringSel, @",", NULL)
		
		&& (*scanFloatImp)(scanner, scanFloatSel, &rect.size.height)
		&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL)
		&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
    {
		return rect;
    }
	else
    {
		[scanner setScanLocation: 0];
		if ((*scanStringImp)(scanner, scanStringSel, @"{", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"x", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &rect.origin.x)
			&& (*scanStringImp)(scanner, scanStringSel, @";", NULL)
			
			&& (*scanStringImp)(scanner, scanStringSel, @"y", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &rect.origin.y)
			&& (*scanStringImp)(scanner, scanStringSel, @";", NULL)
			
			&& (*scanStringImp)(scanner, scanStringSel, @"width", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &rect.size.width)
			&& (*scanStringImp)(scanner, scanStringSel, @";", NULL)
			
			&& (*scanStringImp)(scanner, scanStringSel, @"height", NULL)
			&& (*scanStringImp)(scanner, scanStringSel, @"=", NULL)
			&& (*scanFloatImp)(scanner, scanFloatSel, &rect.size.height)
			&& (*scanStringImp)(scanner, scanStringSel, @"}", NULL))
		{
			return rect;
		}
	}
	
	return NSMakeRect(0, 0, 0, 0);
}

