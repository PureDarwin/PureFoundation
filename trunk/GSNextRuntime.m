/* Implementation to allow compilation of GNU objc code with NeXT runtime
   Copyright (C) 1993,1994 Free Software Foundation, Inc.

   Author: Kresten Krab Thorup
   Modified by: Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
   Date: Sep 1994

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
*/

#import <objc/runtime.h>
#import "GSNextRuntime.h"
//#include "config.h"
#include <stdio.h>
//#include "GNUstepBase/preface.h"
#ifndef ROUND
#define ROUND(V, A) \
  ({ __typeof__(V) __v=(V); __typeof__(A) __a=(A); \
     __a*((__v+__a-1)/__a); })
#endif

/*
  return the size of an object specified by type
*/

int
objc_sizeof_type(const char* type)
{
  switch(*type) {
  case _C_ID:
    return sizeof(id);
    break;

  case _C_CLASS:
    return sizeof(Class);
    break;

  case _C_SEL:
    return sizeof(SEL);
    break;

  case _C_CHR:
    return sizeof(char);
    break;

  case _C_UCHR:
    return sizeof(unsigned char);
    break;

  case _C_SHT:
    return sizeof(short);
    break;

  case _C_USHT:
    return sizeof(unsigned short);
    break;

  case _C_INT:
    return sizeof(int);
    break;

  case _C_UINT:
    return sizeof(unsigned int);
    break;

  case _C_LNG:
    return sizeof(long);
    break;

  case _C_ULNG:
    return sizeof(unsigned long);
    break;

  case _C_FLT:
    return sizeof(float);
    break;

  case _C_DBL:
    return sizeof(double);
    break;

  case _C_PTR:
  case _C_ATOM:
  case _C_CHARPTR:
    return sizeof(char*);
    break;

  case _C_ARY_B:
    {
      int len = atoi(type+1);
      while (isdigit(*++type));
      return len*objc_aligned_size (type);
    }
    break;

  case _C_STRUCT_B:
    {
      int acc_size = 0;
      int align;
      while (*type != _C_STRUCT_E && *type++ != '='); /* skip "<name>=" */
      while (*type != _C_STRUCT_E)
	{
	  align = objc_alignof_type (type);       /* padd to alignment */
#if 0
	  acc_size = ROUND (acc_size, align);
#else
//      acc_size = ({int __v=(acc_size); int __a=(align); __a*((__v+__a-1)/__a); });
      {
          int	__v = acc_size;
          int	__a = align;

          acc_size = __a * ((__v + __a - 1) / __a);
      }
#endif
	  acc_size += objc_sizeof_type (type);   /* add component size */
	  type = objc_skip_typespec (type);	         /* skip component */
	}
      return acc_size;
    }

  case _C_UNION_B:
    {
      int max_size = 0;
      while (*type != _C_UNION_E && *type++ != '=') /* do nothing */;
      while (*type != _C_UNION_E)
	{
	  max_size = MAX (max_size, objc_sizeof_type (type));
	  type = objc_skip_typespec (type);
	}
      return max_size;
    }

  default:
    abort();
  }
}


/*
  Return the alignment of an object specified by type
*/

int
objc_alignof_type(const char* type)
{
  switch(*type) {
  case _C_ID:
    return __alignof__(id);
    break;

  case _C_CLASS:
    return __alignof__(Class);
    break;

  case _C_SEL:
    return __alignof__(SEL);
    break;

  case _C_CHR:
    return __alignof__(char);
    break;

  case _C_UCHR:
    return __alignof__(unsigned char);
    break;

  case _C_SHT:
    return __alignof__(short);
    break;

  case _C_USHT:
    return __alignof__(unsigned short);
    break;

  case _C_INT:
    return __alignof__(int);
    break;

  case _C_UINT:
    return __alignof__(unsigned int);
    break;

  case _C_LNG:
    return __alignof__(long);
    break;

  case _C_ULNG:
    return __alignof__(unsigned long);
    break;

  case _C_FLT:
    return __alignof__(float);
    break;

  case _C_DBL:
    return __alignof__(double);
    break;

  case _C_ATOM:
  case _C_CHARPTR:
    return __alignof__(char*);
    break;

  case _C_ARY_B:
    while (isdigit(*++type)) /* do nothing */;
    return objc_alignof_type (type);

  case _C_STRUCT_B:
    {
      struct { int x; double y; } fooalign;
      while (*type != _C_STRUCT_E && *type++ != '=') /* do nothing */;
      if (*type != _C_STRUCT_E)
	return MAX (objc_alignof_type (type), __alignof__ (fooalign));
      else
	return __alignof__ (fooalign);
    }

  case _C_UNION_B:
    {
      int maxalign = 0;
      while (*type != _C_UNION_E && *type++ != '=') /* do nothing */;
      while (*type != _C_UNION_E)
	{
	  maxalign = MAX (maxalign, objc_alignof_type (type));
	  type = objc_skip_typespec (type);
	}
      return maxalign;
    }

  default:
    abort();
  }
}

/*
  The aligned size if the size rounded up to the nearest alignment.
*/

int
objc_aligned_size (const char* type)
{
  int size = objc_sizeof_type (type);
  int align = objc_alignof_type (type);
#if 0
  return ROUND (size, align);
#else
//  return ({int __v=(size); int __a=(align); __a*((__v+__a-1)/__a); });
  int	__v = size;
  int	__a = align;

  return __a * ((__v + __a - 1) / __a);
#endif
}

/*
  The size rounded up to the nearest integral of the wordsize, taken
  to be the size of a void*.
*/

int
objc_promoted_size (const char* type)
{
  int size = objc_sizeof_type (type);
  int wordsize = sizeof (void*);

#if 0
  return ROUND (size, wordsize);
#else
//  return ({int __v=(size); int __a=(wordsize); __a*((__v+__a-1)/__a); });
  int	__v = size;
  int	__a = wordsize;

  return __a * ((__v + __a - 1) / __a);
#endif
}

/*
  Skip type qualifiers.  These may eventually precede typespecs
  occuring in method prototype encodings.
*/

const char*
objc_skip_type_qualifiers (const char* type)
{
  while (*type == _C_CONST
	 || *type == _C_IN
	 || *type == _C_INOUT
	 || *type == _C_OUT
	 || *type == _C_BYCOPY
#ifdef	_C_BYREF
	 || *type == _C_BYREF
#endif
#ifdef	_C_GCINVISIBLE
	 || *type == _C_GCINVISIBLE
#endif
	 || *type == _C_ONEWAY)
    {
      type += 1;
    }
  return type;
}


/*
  Skip one typespec element.  If the typespec is prepended by type
  qualifiers, these are skipped as well.
*/

const char*
objc_skip_typespec (const char* type)
{
  type = objc_skip_type_qualifiers (type);

  switch (*type) {

  case _C_ID:
    /* An id may be annotated by the actual type if it is known
       with the @"ClassName" syntax */

    if (*++type != '"')
      return type;
    else
      {
	while (*++type != '"') /* do nothing */;
	return type + 1;
      }

    /* The following are one character type codes */
  case _C_CLASS:
  case _C_SEL:
  case _C_CHR:
  case _C_UCHR:
  case _C_CHARPTR:
  case _C_ATOM:
  case _C_SHT:
  case _C_USHT:
  case _C_INT:
  case _C_UINT:
  case _C_LNG:
  case _C_ULNG:
  case _C_FLT:
  case _C_DBL:
  case _C_VOID:
    return ++type;
    break;

  case _C_ARY_B:
    /* skip digits, typespec and closing ']' */

    while (isdigit(*++type));
    type = objc_skip_typespec(type);
    if (*type == _C_ARY_E)
      return ++type;
    else
      abort();

  case _C_STRUCT_B:
    /* skip name, and elements until closing '}'  */

    while (*type != _C_STRUCT_E && *type++ != '=');
    while (*type != _C_STRUCT_E) { type = objc_skip_typespec (type); }
    return ++type;

  case _C_UNION_B:
    /* skip name, and elements until closing ')'  */

    while (*type != _C_UNION_E && *type++ != '=');
    while (*type != _C_UNION_E) { type = objc_skip_typespec (type); }
    return ++type;

  case _C_PTR:
    /* Just skip the following typespec */

    return objc_skip_typespec (++type);

  default:
    abort();
  }
}

/*
  Skip an offset as part of a method encoding.  This is prepended by a
  '+' if the argument is passed in registers.
*/
inline const char*
objc_skip_offset (const char* type)
{
  if (*type == '+') type++;
  if (*type == '-') type++;
  while (isdigit(*++type));
  return type;
}

/*
  Skip an argument specification of a method encoding.
*/
const char*
objc_skip_argspec (const char* type)
{
  type = objc_skip_typespec (type);
  type = objc_skip_offset (type);
  return type;
}

unsigned
objc_get_type_qualifiers (const char* type)
{
  unsigned res = 0;
  BOOL flag = YES;

  while (flag)
    switch (*type++)
      {
      case _C_CONST:  res |= _F_CONST; break;
      case _C_IN:     res |= _F_IN; break;
      case _C_INOUT:  res |= _F_INOUT; break;
      case _C_OUT:    res |= _F_OUT; break;
      case _C_BYCOPY: res |= _F_BYCOPY; break;
#ifdef	_C_BYREF
      case _C_BYREF:  res |= _F_BYREF; break;
#endif
      case _C_ONEWAY: res |= _F_ONEWAY; break;
#ifdef	_C_GCINVISIBLE
      case _C_GCINVISIBLE:  res |= _F_GCINVISIBLE; break;
#endif
      default: flag = NO;
    }

  return res;
}

/* Returns YES iff t1 and t2 have same method types, but we ignore
   the argframe layout */
BOOL
sel_types_match (const char* t1, const char* t2)
{
  if (!t1 || !t2)
    return NO;
  while (*t1 && *t2)
    {
      if (*t1 == '+') t1++;
      if (*t1 == '-') t1++;
      if (*t2 == '+') t2++;
      if (*t2 == '-') t2++;
      while (isdigit(*t1)) t1++;
      while (isdigit(*t2)) t2++;
      /* xxx Remove these next two lines when qualifiers are put in
	  all selectors, not just Protocol selectors. */
      t1 = objc_skip_type_qualifiers(t1);
      t2 = objc_skip_type_qualifiers(t2);
      if (!*t1 && !*t2)
	return YES;
      if (*t1 != *t2)
	return NO;
      t1++;
      t2++;
    }
  return NO;
}

/*
 *	The remainder of this file was removed
 */

/* Step through method encoding information extracting details.
 * If outTypes is non-nul then we copy the argument type into
 * the buffer as a nul terminated string and use the values in
 * this buffer as the types in info, rather than pointers to
 * positions in typePtr
 */
const char *
mframe_next_arg(const char *typePtr, NSArgumentInfo *info, char *outTypes)
{
	NSArgumentInfo	local;
	BOOL			flag;
	BOOL			negative = NO;
	
	if (info == 0)
    {
		info = &local;
    }
	/*
	 *	Skip past any type qualifiers - if the caller wants them, return them.
	 */
	flag = YES;
	info->qual = 0;
	while (flag)
    {
		switch (*typePtr)
		{
			case _C_CONST:  info->qual |= _F_CONST; break;
			case _C_IN:     info->qual |= _F_IN; break;
			case _C_INOUT:  info->qual |= _F_INOUT; break;
			case _C_OUT:    info->qual |= _F_OUT; break;
			case _C_BYCOPY: info->qual |= _F_BYCOPY; break;
#ifdef	_C_BYREF
			case _C_BYREF:  info->qual |= _F_BYREF; break;
#endif
			case _C_ONEWAY: info->qual |= _F_ONEWAY; break;
#ifdef	_C_GCINVISIBLE
			case _C_GCINVISIBLE:  info->qual |= _F_GCINVISIBLE; break;
#endif
			default: flag = NO;
		}
		if (flag)
		{
			typePtr++;
		}
    }
	
	info->type = typePtr;
	
	/*
	 *	Scan for size and alignment information.
	 */
	switch (*typePtr++)
    {
		case _C_ID:
			info->size = sizeof(id);
			info->align = __alignof__(id);
			break;
			
		case _C_CLASS:
			info->size = sizeof(Class);
			info->align = __alignof__(Class);
			break;
			
		case _C_SEL:
			info->size = sizeof(SEL);
			info->align = __alignof__(SEL);
			break;
			
		case _C_CHR:
			info->size = sizeof(char);
			info->align = __alignof__(char);
			break;
			
		case _C_UCHR:
			info->size = sizeof(unsigned char);
			info->align = __alignof__(unsigned char);
			break;
			
		case _C_SHT:
			info->size = sizeof(short);
			info->align = __alignof__(short);
			break;
			
		case _C_USHT:
			info->size = sizeof(unsigned short);
			info->align = __alignof__(unsigned short);
			break;
			
		case _C_INT:
			info->size = sizeof(int);
			info->align = __alignof__(int);
			break;
			
		case _C_UINT:
			info->size = sizeof(unsigned int);
			info->align = __alignof__(unsigned int);
			break;
			
		case _C_LNG:
			info->size = sizeof(long);
			info->align = __alignof__(long);
			break;
			
		case _C_ULNG:
			info->size = sizeof(unsigned long);
			info->align = __alignof__(unsigned long);
			break;
			
		case _C_LNG_LNG:
			info->size = sizeof(long long);
			info->align = __alignof__(long long);
			break;
			
		case _C_ULNG_LNG:
			info->size = sizeof(unsigned long long);
			info->align = __alignof__(unsigned long long);
			break;
			
		case _C_FLT:
			info->size = sizeof(float);
			info->align = __alignof__(float);
			break;
			
		case _C_DBL:
			info->size = sizeof(double);
			info->align = __alignof__(double);
			break;
			
		case _C_PTR:
			info->size = sizeof(char*);
			info->align = __alignof__(char*);
			if (*typePtr == '?')
			{
				typePtr++;
			}
			else
			{
				typePtr = objc_skip_typespec(typePtr);
			}
			break;
			
		case _C_ATOM:
		case _C_CHARPTR:
			info->size = sizeof(char*);
			info->align = __alignof__(char*);
			break;
			
		case _C_ARY_B:
		{
			int	length = atoi(typePtr);
			
			while (isdigit(*typePtr))
			{
				typePtr++;
			}
			typePtr = mframe_next_arg(typePtr, &local, 0);
			info->size = length * ROUND(local.size, local.align);
			info->align = local.align;
			typePtr++;	/* Skip end-of-array	*/
		}
			break;
			
		case _C_STRUCT_B:
		{
			unsigned int acc_size = 0;
			unsigned int def_align = objc_alignof_type(typePtr-1);
			unsigned int acc_align = def_align;
			const char	*ptr = typePtr;
			
			/*
			 *	Skip "<name>=" stuff.
			 */
			while (*ptr != _C_STRUCT_E && *ptr != '=') ptr++;
			if (*ptr == '=') typePtr = ptr;
			typePtr++;
			
			/*
			 *	Base structure alignment on first element.
			 */
			if (*typePtr != _C_STRUCT_E)
			{
				typePtr = mframe_next_arg(typePtr, &local, 0);
				if (typePtr == 0)
				{
					return 0;		/* error	*/
				}
				acc_size = ROUND(acc_size, local.align);
				acc_size += local.size;
				acc_align = MAX(local.align, def_align);
			}
			/*
			 *	Continue accumulating structure size
			 *	and adjust alignment if necessary
			 */
			while (*typePtr != _C_STRUCT_E)
			{
				typePtr = mframe_next_arg(typePtr, &local, 0);
				if (typePtr == 0)
				{
					return 0;		/* error	*/
				}
				acc_size = ROUND(acc_size, local.align);
				acc_size += local.size;
				acc_align = MAX(local.align, acc_align);
			}
			/*
			 * Size must be a multiple of alignment
			 */
			if (acc_size % acc_align != 0)
			{
				acc_size += acc_align - acc_size % acc_align;
			}
			info->size = acc_size;
			info->align = acc_align;
			typePtr++;	/* Skip end-of-struct	*/
		}
			break;
			
		case _C_UNION_B:
		{
			unsigned int	max_size = 0;
			unsigned int	max_align = 0;
			
			/*
			 *	Skip "<name>=" stuff.
			 */
			while (*typePtr != _C_UNION_E)
			{
				if (*typePtr++ == '=')
				{
					break;
				}
			}
			while (*typePtr != _C_UNION_E)
			{
				typePtr = mframe_next_arg(typePtr, &local, 0);
				if (typePtr == 0)
				{
					return 0;		/* error	*/
				}
				max_size = MAX(max_size, local.size);
				max_align = MAX(max_align, local.align);
			}
			info->size = max_size;
			info->align = max_align;
			typePtr++;	/* Skip end-of-union	*/
		}
			break;
			
		case _C_VOID:
			info->size = 0;
			info->align = __alignof__(char*);
			break;
			
		default:
			return 0;
    }
	
	if (typePtr == 0)
    {		/* Error condition.	*/
		return 0;
    }
	
	/* Copy tye type information into the buffer if provided.
	 */
	if (outTypes != 0)
    {
		unsigned	len = typePtr - info->type;
		
		strncpy(outTypes, info->type, len);
		outTypes[len] = '\0';
		info->type = outTypes;
    }
	
	/*
	 *	May tell the caller if the item is stored in a register.
	 */
	if (*typePtr == '+')
    {
		typePtr++;
		info->isReg = YES;
    }
	else
    {
		info->isReg = NO;
    }
	/*
	 * Cope with negative offsets.
	 */
	if (*typePtr == '-')
    {
		typePtr++;
		negative = YES;
    }
	/*
	 *	May tell the caller what the stack/register offset is for
	 *	this argument.
	 */
	info->offset = 0;
	while (isdigit(*typePtr))
    {
		info->offset = info->offset * 10 + (*typePtr++ - '0');
    }
	if (negative == YES)
    {
		info->offset = -info->offset;
    }
	
	return typePtr;
}






