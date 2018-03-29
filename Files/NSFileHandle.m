/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSFileHandle.m
 *
 *	NSFileHandle
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSFileHandle.h"
#import "PFFileHandle.h"

/*
 *	Constants
 */
NSString * const NSFileHandleOperationException = @"NSFileHandleOperationException";

NSString * const NSFileHandleReadCompletionNotification = @"NSFileHandleReadCompletionNotification";
NSString * const NSFileHandleReadToEndOfFileCompletionNotification = @"NSFileHandleReadToEndOfFileCompletionNotification";
NSString * const NSFileHandleConnectionAcceptedNotification = @"NSFileHandleConnectionAcceptedNotification";
NSString * const NSFileHandleDataAvailableNotification = @"NSFileHandleDataAvailableNotification";

NSString * const NSFileHandleNotificationDataItem = @"NSFileHandleNotificationDataItem";
NSString * const NSFileHandleNotificationFileHandleItem = @"NSFileHandleNotificationFileHandleItem";
NSString * const NSFileHandleNotificationMonitorModes = @"NSFileHandleNotificationMonitorModes";


/*
 *	NSFileHandle is the front-end to a class cluster, which currently consists of just
 *	our PFFileHandle class. All class creation is forwarded to it.
 */
@implementation NSFileHandle

/*
 *	NSFileHandleCreation class creation methods
 */
+(id)alloc
{
	if( self == [NSFileHandle class])
		return [PFFileHandle alloc];
	return [super alloc];
}

+ (id)fileHandleWithStandardInput
{
	PF_HELLO("")
	return [PFFileHandle fileHandleWithStandardInput];
}

+ (id)fileHandleWithStandardOutput
{
	PF_HELLO("")
	return [PFFileHandle fileHandleWithStandardOutput];
}

+ (id)fileHandleWithStandardError
{
	PF_HELLO("")
	return [PFFileHandle fileHandleWithStandardError];
}

+ (id)fileHandleWithNullDevice
{
	PF_HELLO("")
	return [PFFileHandle fileHandleWithNullDevice];
}


+ (id)fileHandleForReadingAtPath:(NSString *)path
{
	PF_HELLO("")
	return [PFFileHandle fileHandleForReadingAtPath: path];
}

+ (id)fileHandleForWritingAtPath:(NSString *)path
{
	PF_HELLO("")
	return [PFFileHandle fileHandleForWritingAtPath: path];
}

+ (id)fileHandleForUpdatingAtPath:(NSString *)path
{
	PF_HELLO("")
	return [PFFileHandle fileHandleForUpdatingAtPath: path];
}

/*
 *	NSFileHandle instance methods, to keep the compiler happy
 */
- (NSData *)availableData { return nil; }
- (NSData *)readDataToEndOfFile { return nil; }
- (NSData *)readDataOfLength:(NSUInteger)length { return nil; }
- (void)writeData:(NSData *)data {}
- (unsigned long long)offsetInFile { return 0; }
- (unsigned long long)seekToEndOfFile { return 0; }
- (void)seekToFileOffset:(unsigned long long)offset {}
- (void)truncateFileAtOffset:(unsigned long long)offset {}
- (void)synchronizeFile {}
- (void)closeFile {}

@end
