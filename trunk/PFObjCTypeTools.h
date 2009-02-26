/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFObjCTypeTools.h
 *
 *	Functions for parsing method description strings
 *
 *	Created by Stuart Crook on 07/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#include <ffi/ffi.h>

/*
 *	obj-c method descriptor encodings apparently not exported from objc4
 */
#define _C_IN		'n'
#define _C_INOUT	'N'
#define _C_OUT		'o'
#define _C_BYCOPY	'O'
#define _C_BYREF	'R'
#define _C_ONEWAY	'V'

#define _C_LNGLNG 'q'

/*
 *	Final collection of functions
 */
const char *pfenc_process(const char *type, NSUInteger *size, NSUInteger *offset);
const char *pfenc_skip(const char* type);
const char *pfenc_size_align(const char *type, NSUInteger *size, NSUInteger *alignment);
const char *pfenc_offset(const char *type, NSUInteger *offset);
const char *pfenc_copy(const char *type);

/*
 *	These are our versions of the functions we patched the objc4 runtime to 
 *	export.
 */
unsigned int pf_encoding_getNumberOfArguments(const char *typedesc);
unsigned int pf_encoding_getSizeOfArguments(const char *typedesc);
char *pf_encoding_copyReturnType(const char *t);
char *pf_encoding_copyArgumentType(const char *t, unsigned int index);


unsigned int pf_get_offset(const char **typedesc);


// from Cocotron
//ffi_type* array_to_ffi_type(const char* argtype);
//ffi_type* struct_to_ffi_type(const char* argtype);

// need this last one
//ffi_type* signature_to_ffi_type(const char* argtype);