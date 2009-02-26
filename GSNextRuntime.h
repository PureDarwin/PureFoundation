/*
 *  This file was created to ease the importing of certain functions from the 
 *	GNUStep file GSNextRuntime.h
 */

/*
 *	obj-c method descriptor encodings apparently not exported from objc4
 */
#define _C_IN		'n'
#define _C_INOUT	'N'
#define _C_OUT		'o'
#define _C_BYCOPY	'O'
#define _C_BYREF	'R'
#define _C_ONEWAY	'V'

#define _F_CONST	1
#define _F_IN		2
#define _F_INOUT	3
#define _F_OUT		4
#define _F_BYCOPY	5
#define _F_BYREF	6
#define _F_ONEWAY	7

/*
 *	Functions from GSNextRuntime.m
 */
int objc_sizeof_type(const char* type);
int objc_alignof_type(const char* type);
int objc_aligned_size (const char* type);
int objc_promoted_size (const char* type);
const char*objc_skip_type_qualifiers (const char* type);
const char*objc_skip_typespec (const char* type);
const char*objc_skip_offset (const char* type); //inline
const char*objc_skip_argspec (const char* type);
unsigned objc_get_type_qualifiers (const char* type);


/*
 *	From GNUStep's NSObjCRuntime.h
 */
typedef struct	{
	int		offset;
	unsigned	size;
	const char	*type;
	unsigned	align;
	unsigned	qual;
	BOOL		isReg;
} NSArgumentInfo;

/*
 *	From mframe.m
 */
const char *mframe_next_arg(const char *typePtr, NSArgumentInfo *info, char *outTypes);
