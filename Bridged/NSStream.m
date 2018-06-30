/*
 *	PureFoundation -- https://puredarwin.org
 *	NSStream.m
 *
 *	NSStream, NSInputStream, NSOutputStream
 *
 *	Created by Stuart Crook on 29/01/2009.
 */

#import "NSStream.h"

// The NSStream abstract superclass and various NSInputStream and NSOutputStream init methods are implemented here.
// Everything else is implemented in CF.

@implementation NSStream (NSStream)

#pragma mark - instance method prototypes

- (void)open {}
- (void)close {}
- (id)delegate { return nil; }
- (void)setDelegate:(id)delegate { }
- (id)propertyForKey:(NSString *)key { return nil; }
- (BOOL)setProperty:(id)property forKey:(NSString *)key { return NO; }
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (NSStreamStatus)streamStatus { return NSStreamStatusNotOpen; }
- (NSError *)streamError { return nil; }

@end

@implementation NSStream (NSSocketStreamCreationExtensions)

// TODO:
// t +[NSStream(NSSocketStreamCreationExtensions) getStreamsToHostWithName:port:inputStream:outputStream:]
// t +[NSStream(NSStreamBoundPairCreationExtensions) getBoundStreamsWithBufferSize:inputStream:outputStrea

+ (void)getStreamsToHost:(NSHost *)host
                    port:(NSInteger)port
             inputStream:(NSInputStream **)inputStream
            outputStream:(NSOutputStream **)outputStream
{
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)[host address], port,
                                       (CFReadStreamRef *)inputStream, (CFWriteStreamRef *)outputStream);
}

@end
                     
@implementation NSInputStream (NSInputStream)

// TODO:
// t +[NSInputStream(NSInputStream) inputStreamWithData:]
// t +[NSInputStream(NSInputStream) inputStreamWithFileAtPath:]
// t +[NSInputStream(NSInputStream) inputStreamWithURL:]
// t -[NSInputStream(NSInputStream) initWithData:]
// t -[NSInputStream(NSInputStream) initWithFileAtPath:]
// t -[NSInputStream(NSInputStream) initWithURL:]

#pragma mark - instance method prototypes

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len { return 0; }
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len { return NO; }
- (BOOL)hasBytesAvailable { return NO; }

@end

@implementation NSOutputStream (NSOutputStream)

// TODO:
// t +[NSOutputStream(NSOutputStream) outputStreamToBuffer:capacity:]
// t +[NSOutputStream(NSOutputStream) outputStreamToFileAtPath:append:]
// t +[NSOutputStream(NSOutputStream) outputStreamToMemory]
// t +[NSOutputStream(NSOutputStream) outputStreamWithURL:append:]
// t -[NSOutputStream(NSOutputStream) initWithURL:append:]
// t -[__NSCFOutputStream initToFileAtPath:append:]

- (id)initToMemory {
    free(self);
    return (id)CFWriteStreamCreateWithAllocatedBuffers(kCFAllocatorDefault, kCFAllocatorDefault);
}

- (id)initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity {
    free(self);
    if (!buffer || !capacity) return nil;
    return (id)CFWriteStreamCreateWithBuffer(kCFAllocatorDefault, (UInt8 *)buffer, capacity);
}

#pragma mark - instance method prototypes

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len { return 0; }
- (BOOL)hasSpaceAvailable { return NO; }

@end
