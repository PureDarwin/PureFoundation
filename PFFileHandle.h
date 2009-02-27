/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFFileHandle.h
 *
 *	PFFileHandle
 *
 *	Created by Stuart Crook on 06/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSFileHandle.h"

@interface PFFileHandle : NSFileHandle
{
	int _fileDescriptor;
	uint8_t _mode;	// read/write values #define in .m
	BOOL _isFile;	// the alternative is a socket/FIFO
	BOOL _fileIsOpen;
	BOOL _closeFile;
}

// NSFileHandleCreation
+ (id)fileHandleWithStandardInput;
+ (id)fileHandleWithStandardOutput;
+ (id)fileHandleWithStandardError;
+ (id)fileHandleWithNullDevice;

+ (id)fileHandleForReadingAtPath:(NSString *)path;
+ (id)fileHandleForWritingAtPath:(NSString *)path;
+ (id)fileHandleForUpdatingAtPath:(NSString *)path;

-(void)dealloc;

// "platform specific"
- (id)initWithFileDescriptor:(int)fd closeOnDealloc:(BOOL)closeopt;
- (id)initWithFileDescriptor:(int)fd;
- (int)fileDescriptor;

// NSFileHandle
- (NSData *)availableData;

- (NSData *)readDataToEndOfFile;
- (NSData *)readDataOfLength:(NSUInteger)length;

- (void)writeData:(NSData *)data;

- (unsigned long long)offsetInFile;
- (unsigned long long)seekToEndOfFile;
- (void)seekToFileOffset:(unsigned long long)offset;

- (void)truncateFileAtOffset:(unsigned long long)offset;
- (void)synchronizeFile;
- (void)closeFile;

// Asynchronous (TODO)
//- (void)readInBackgroundAndNotifyForModes:(NSArray *)modes;
//- (void)readInBackgroundAndNotify;

//- (void)readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes;
//- (void)readToEndOfFileInBackgroundAndNotify;

//- (void)acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes;
//- (void)acceptConnectionInBackgroundAndNotify;

//- (void)waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes;
//- (void)waitForDataInBackgroundAndNotify;


@end
