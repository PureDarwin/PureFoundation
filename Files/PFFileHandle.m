/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFFileHandle.m
 *
 *	PFFileHandle
 *
 *	Created by Stuart Crook on 06/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "PFFileHandle.h"
#include <fcntl.h>
#include <sys/stat.h>

#define PF_FILE_READ	1
#define PF_FILE_WRITE	2

/*
 *	Shared instances of standard file handles
 */
static PFFileHandle *_PFNullFileHandle = nil;
static PFFileHandle *_PFStdinFileHandle = nil;
static PFFileHandle *_PFStdoutFileHandle = nil;
static PFFileHandle *_PFStderrFileHandle = nil;

@implementation PFFileHandle

// NSFileHandleCreation
+ (id)fileHandleWithStandardInput
{
	PF_HELLO("")
	if( _PFStdinFileHandle == nil )
		_PFStdinFileHandle = [[self alloc] initWithFileDescriptor: STDIN_FILENO];
	return _PFStdinFileHandle;
}

+ (id)fileHandleWithStandardOutput
{
	PF_HELLO("")
	if( _PFStdoutFileHandle == nil )
		_PFStdoutFileHandle = [[self alloc] initWithFileDescriptor: STDOUT_FILENO];
	return _PFStdoutFileHandle;
}

+ (id)fileHandleWithStandardError
{
	PF_HELLO("")
	if( _PFStderrFileHandle == nil )
		_PFStderrFileHandle = [[self alloc] initWithFileDescriptor: STDERR_FILENO];
	return _PFStderrFileHandle;
}

+ (id)fileHandleWithNullDevice
{
	PF_HELLO("")
	if( _PFNullFileHandle == nil )
	{
		// should we actually open a path to /dev/null ???
		//_PFNullFileHandle = [self alloc];
		//_PFNullFileHandle->_fileDescriptor = NULL;
		int filedesc = open("/dev/null", O_RDWR);
		if( filedesc == -1 ) 
		{
			NSLog(@"PFFileHandle faile to open '/dev/null'");
			return nil;
		}
		_PFNullFileHandle = [[self alloc] initWithFileDescriptor: filedesc closeOnDealloc: YES];
	}
	return _PFNullFileHandle;
}


+ (id)fileHandleForReadingAtPath:(NSString *)path
{
	PF_HELLO("")
	const char *filename = [path fileSystemRepresentation];
	//printf("got filename '%s'\n", filename);
	if( filename == NULL ) return nil;
	//printf("going to attempt to open it\n");
	int filedesc = open(filename, O_RDONLY);
	//printf("got a filedesc of %u\n", filedesc);
	if( filedesc == -1 )
	{
		NSLog(@"PFFileHandle failed to open '%@' for reading, errno = %u", path, errno);
		return nil;
	}
	//printf("calling alloc, etc.\n");
	return [[[self alloc] initWithFileDescriptor: filedesc closeOnDealloc: YES] autorelease];
}

+ (id)fileHandleForWritingAtPath:(NSString *)path
{
	PF_HELLO("")
	const char *filename = [path fileSystemRepresentation];
	//printf("got filename '%s'\n", filename);
	if( filename == NULL ) return nil;
	//printf("going to attempt to open it\n");
	int filedesc = open(filename, O_WRONLY);
	//printf("got a filedesc of %u\n", filedesc);
	if( filedesc == -1 )
	{
		NSLog(@"PFFileHandle failed to open '%@' for writing, errno = %u", path, errno);
		return nil;
	}
	return [[[self alloc] initWithFileDescriptor: filedesc closeOnDealloc: YES] autorelease];
}

+ (id)fileHandleForUpdatingAtPath:(NSString *)path
{
	PF_HELLO("")
	const char *filename = [path fileSystemRepresentation];
	if( filename == NULL ) return nil;
	int filedesc = open(filename, O_RDWR);
	if( filedesc == -1 )
	{
		NSLog(@"PFFileHandle failed to open '%@' for writing, errno = %u", path, errno);
		return nil;
	}
	return [[[self alloc] initWithFileDescriptor: filedesc closeOnDealloc: YES] autorelease];
}


-(void)dealloc
{
	if( (_closeFile == YES) && (_fileIsOpen == YES) ) 
		[self closeFile];
	[super dealloc];
}

// "platform specific"
/*
 *	This is the main method, called into by all the other creation methods
 */
- (id)initWithFileDescriptor:(int)fd closeOnDealloc:(BOOL)closeopt
{
	int mode = fcntl(fd, F_GETFL);
	//if( mode == -1 )
	//{
	//	NSLog(@"PFFileHandle coundn't fcntl() file descriptor, errno = %u", errno);
	//	return nil; // <- this leaks this object
	//}
	switch (mode) 
	{
		case -1:
			NSLog(@"PFFileHandle coundn't fcntl() file descriptor, errno = %u", errno);
			return nil; // <- this leaks this object
		case O_RDONLY:
			_mode = PF_FILE_READ;
			break;
		case O_WRONLY:
			_mode = PF_FILE_WRITE;
			break;
		case O_RDWR:
			_mode = (PF_FILE_READ | PF_FILE_WRITE);
	}
	
	struct stat statbuf;
    if (fstat (fd, &statbuf) == -1) 
	{
		NSLog (@"PFFileHandle couldn't fstat() file descriptor, errno = %u", errno);
		return nil; // <- this also leaks
	}

	if( ((statbuf.st_mode & S_IFIFO) != 0) || ((statbuf.st_mode & S_IFSOCK) != 0) ) _isFile = NO;
	else if( ((statbuf.st_mode & S_IFREG) != 0) ) _isFile = YES;
	else
	{
		NSLog(@"File was neither regular or sockect/FIFO");
		return nil; // <- we're leaking a lot here, aren't we
	}
	
	// set other flags
	_fileIsOpen = YES;
	_fileDescriptor = fd;
	_closeFile = closeopt;
	return self;
}

- (id)initWithFileDescriptor:(int)fd
{
	return [self initWithFileDescriptor: fd closeOnDealloc: NO];
}

- (int)fileDescriptor
{
	if( _fileIsOpen == NO )
		[NSException raise: NSGenericException format: nil]; // check which it should raise
	return _fileDescriptor;
}

// NSFileHandle
- (NSData *)availableData 
{ 
	if( (_fileIsOpen == NO) || ((_mode | PF_FILE_READ) == 0) )
		[NSException raise: NSFileHandleOperationException format: @"Attempt to read from write-only handle"];
	
	// determine how much data to read: the rest of the file, or just a bufferful
	NSUInteger length;
	struct stat statbuf;
	if (fstat (_fileDescriptor, &statbuf) == -1) 
		[NSException raise: NSFileHandleOperationException format: @"fstat() errno = %u", errno];
	
	if( _isFile == YES )
	{
		length = statbuf.st_size - lseek(_fileDescriptor, 0, SEEK_CUR);
	}
	else // socket/FIFO
	{
		//length = statbuf.st_blksize; // is this right???
		// getsockopt SO_RCVBUF
	}
	
	if( length == 0 ) return [NSData data];
	void *buffer = malloc(length);
	
	if( (length = read(_fileDescriptor, buffer, length)) == -1 )
		[NSException raise: NSFileHandleOperationException format: @"read() error %u", errno];

	if( length == 0 ) return [NSData data];

	CFDataRef data = CFDataCreate( kCFAllocatorDefault, (const UInt8 *)buffer, length);
	free(buffer);
	PF_RETURN_TEMP(data)
}

- (NSData *)readDataToEndOfFile 
{ 
	if( (_fileIsOpen == NO) || ((_mode | PF_FILE_READ) == 0) )
		[NSException raise: NSFileHandleOperationException format: @"Attempt to read from write-only handle"];
	
	return nil; 
}

- (NSData *)readDataOfLength:(NSUInteger)length 
{ 
	if( (_fileIsOpen == NO) || ((_mode | PF_FILE_READ) == 0) )
		[NSException raise: NSFileHandleOperationException format: @"Attempt to read from write-only handle"];

	// adjust length downwards if _isFile, according to file's length

	
	return nil; 
}


- (void)writeData:(NSData *)data 
{ 
	if( (_fileIsOpen == NO) || ((_mode | PF_FILE_WRITE) == 0) )
		[NSException raise: NSFileHandleOperationException format: @"File is closed"];

	NSUInteger length;
	if( (data == nil) || ((length = [data length]) == 0) ) return; // check this behaviour

	const void *bytes = [data bytes];
	
	if( write(_fileDescriptor, bytes, length) == -1 )
		[NSException raise: NSFileHandleOperationException format: @"write() error %u", errno];
	
	return; 
}


- (unsigned long long)offsetInFile 
{
	if( (_fileIsOpen == NO) || (_isFile == NO) )
		[NSException raise: NSFileHandleOperationException format: @"Cannot seek in socket/FIFO"];
	return lseek(_fileDescriptor, 0, SEEK_CUR); // this should work...
}


- (unsigned long long)seekToEndOfFile 
{
	if( (_fileIsOpen == NO) || (_isFile == NO) )
		[NSException raise: NSFileHandleOperationException format: @"Cannot seek in socket/FIFO"];
	unsigned long long position = lseek(_fileDescriptor, 0, SEEK_END);
	if( position == -1 )
		[NSException raise: NSFileHandleOperationException format: @"lseek() error %u", errno];
	return position;
}

- (void)seekToFileOffset:(unsigned long long)offset 
{
	if( (_fileIsOpen == NO) || (_isFile == NO) )
		[NSException raise: NSFileHandleOperationException format: @"Cannot seek in socket/FIFO"];
	if( lseek(_fileDescriptor, offset, SEEK_SET) == -1 )
		[NSException raise: NSFileHandleOperationException format: @"lseek() error %u", errno];
}


- (void)truncateFileAtOffset:(unsigned long long)offset 
{
	if( (_fileIsOpen == NO) || (_isFile == NO) )
		[NSException raise: NSFileHandleOperationException format: @"Truncate of non-file"];
	
	if( ftruncate(_fileDescriptor, offset) == -1 )
		[NSException raise: NSFileHandleOperationException format: @"ftruncate() error %u", errno];
}



- (void)synchronizeFile 
{
	if( (_fileIsOpen == NO) || (_isFile == NO) )
		[NSException raise: NSFileHandleOperationException format: @"Attempted sync on non-file"];

	// should we use F_FULLFSYNC fcntl ???
	if( fsync(_fileDescriptor) == -1 )
		[NSException raise: NSFileHandleOperationException format: @"fsync() error %u", errno];
}


/*
 *	From the docs, this should just mark the NSFileHandle object as closed. Closing
 *	the file (eg. close(_fileDescriptor) doesn't occur until deallocation.
 */
- (void)closeFile
{
	if( _fileIsOpen == YES )
	{
		//fclose( _fileDescriptor );
		//_fileDescriptor = 0;
		_fileIsOpen == NO;
	}
}

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
