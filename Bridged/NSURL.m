/*
 *	PureFoundation -- http://puredarwin.org
 *	NSURL.m
 *
 *	Created by Stuart Crook on 29/01/2009.
 */

// NSURL is declared in CF, but almost all of the methods are implemented in Foundation
// NSURL is the bridged class, so all methods here will be implemented on top of CFURLRef

// Constants
// Values have been checked against macOS
NSString *const NSURLErrorDomain = @"NSURLErrorDomain";
NSString *const NSURLErrorFailingURLErrorKey = @"NSErrorFailingURLKey";
NSString *const NSURLErrorFailingURLPeerTrustErrorKey = @"NSURLErrorFailingURLPeerTrustErrorKey";
NSString *const NSURLErrorFailingURLStringErrorKey = @"NSErrorFailingURLStringKey";

NSString *NSURLFileScheme = @"file";

// TODO: Disable -Wobjc-protocol-method-implementation across entire class

#define SELF    ((CFURLRef)self)

@implementation NSURL (NSURL)

#pragma mark - factory methods

// TODO:
// t +[NSURL(NSURL) URLByResolvingAliasFileAtURL:options:error:]
// t +[NSURL(NSURL) URLByResolvingBookmarkData:options:relativeToURL:bookmarkDataIsStale:error:]
// t +[NSURL(NSURL) URLWithDataRepresentation:relativeToURL:]
// t +[NSURL(NSURL) absoluteURLWithDataRepresentation:relativeToURL:]
// t +[NSURL(NSURL) fileURLWithFileSystemRepresentation:isDirectory:relativeToURL:]
// t +[NSURL(NSURL) fileURLWithPath:isDirectory:relativeToURL:]
// t +[NSURL(NSURL) fileURLWithPath:relativeToURL:]

+ (id)URLWithString:(NSString *)URLString {
    return [(id)CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)URLString, NULL) autorelease];
}

+ (id)URLWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL {
    return [(id)CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)URLString, (CFURLRef)baseURL) autorelease];
}

// Better to use fileURLWithPath:isDirectory: if you know if the path is a file vs directory, as it saves an i/o.
+ (id)fileURLWithPath:(NSString *)path {
    // TODO: Examine the file system to see if path points to a directory
    return [(id)CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false) autorelease];
}

+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir {
    return [(id)CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, isDir) autorelease];
}

#pragma mark - initialisers

// t -[NSURL(NSURL) initAbsoluteURLWithDataRepresentation:relativeToURL:]
// t -[NSURL(NSURL) initByResolvingAliasFileAtURL:options:error:]
// t -[NSURL(NSURL) initByResolvingBookmarkData:options:relativeToURL:bookmarkDataIsStale:error:]
// t -[NSURL(NSURL) initFileURLWithFileSystemRepresentation:isDirectory:relativeToURL:]
// t -[NSURL(NSURL) initFileURLWithPath:isDirectory:relativeToURL:]
// t -[NSURL(NSURL) initFileURLWithPath:relativeToURL:]
// t -[NSURL(NSURL) initWithDataRepresentation:relativeToURL:]

- (id)initWithString:(NSString *)URLString {
    free(self);
    return (id)CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)URLString, NULL);
}

- (id)initWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL {
    free(self);
    return (id)CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)URLString, (CFURLRef)baseURL);
}

- (id)initFileURLWithPath:(NSString *)path {
    free(self);
    // TODO: Should check whether path points to a directory
    return (id)CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
}

- (id)initFileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir {
    free(self);
    return (id)CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, isDir);
}

-(id)initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path {
    // TODO: Implement this when we have NSURLComponents
    free(self);
    return nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder { }
+ (BOOL)supportsSecureCoding { return YES; }

#pragma mark - instace methods

// t -[NSURL(NSURL) URLHandle:resourceDataDidBecomeAvailable:]
// t -[NSURL(NSURL) URLHandle:resourceDidFailLoadingWithReason:]
// t -[NSURL(NSURL) URLHandleResourceDidBeginLoading:]
// t -[NSURL(NSURL) URLHandleResourceDidCancelLoading:]
// t -[NSURL(NSURL) URLHandleResourceDidFinishLoading:]
// t -[NSURL(NSURL) URLHandleUsingCache:]
// t -[NSURL(NSURL) connection:didFailWithError:]
// t -[NSURL(NSURL) connection:didReceiveData:]
// t -[NSURL(NSURL) connectionDidFinishLoading:]
// t -[NSURL(NSURL) dataRepresentation]
// t -[NSURL(NSURL) fileSystemRepresentation]
// t -[NSURL(NSURL) getFileSystemRepresentation:maxLength:]
// t -[NSURL(NSURL) hasDirectoryPath]
// t -[NSURL(NSURL) isEqual:]
// t -[NSURL(NSURL) loadResourceDataNotifyingClient:usingCache:]
// t -[NSURL(NSURL) propertyForKey:]
// t -[NSURL(NSURL) relativePath]
// t -[NSURL(NSURL) relativeString]
// t -[NSURL(NSURL) resourceDataUsingCache:]
// t -[NSURL(NSURL) setProperty:forKey:]
// t -[NSURL(NSURL) setResourceData:]
// t -[NSURL(NSURL) standardizedURL]

- (CFTypeID)_cfTypeID {
    return CFURLGetTypeID();
}

- (CFURLRef)_cfurl {
    return SELF;
}

- (NSString *)absoluteString {
    PF_TODO
    return nil;
}

- (NSURL *)absoluteURL {
    return [(id)CFURLCopyAbsoluteURL(SELF) autorelease];
}

- (NSURL *)baseURL {
    return (id)CFURLGetBaseURL(SELF);
}

-(NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)fragment {
    // TODO: Work out the escaped characters parameter here
    return [(id)CFURLCopyFragment(SELF, NULL) autorelease];
}

- (NSString *)host {
    return [(id)CFURLCopyHostName(SELF) autorelease];
}

- (BOOL)isFileURL {
    CFStringRef scheme = CFURLCopyScheme(SELF);
    BOOL result = CFStringCompare(scheme, (CFStringRef)NSURLFileScheme, 0) == kCFCompareEqualTo;
    CFRelease(scheme);
    return result;
}

- (NSString *)parameterString {
    // TODO: Work out the escaped characters parameter here
    return [(id)CFURLCopyParameterString(SELF, NULL) autorelease];
}

- (NSString *)password {
    return [(id)CFURLCopyPassword(SELF) autorelease];
}

- (NSString *)path {
    return [(id)CFURLCopyPath(SELF) autorelease];
}

- (NSNumber *)port {
    SInt32 port = CFURLGetPortNumber(SELF);
    return [(id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &port) autorelease];
}

- (NSString *)query {
    // TODO: Work out the escaped characters parameter here
    return [(id)CFURLCopyQueryString(SELF, NULL) autorelease];
}

- (NSString *)resourceSpecifier {
    return [(id)CFURLCopyResourceSpecifier(SELF) autorelease];
}

- (NSString *)scheme {
    return [(id)CFURLCopyScheme(SELF) autorelease];
}

- (NSString *)user {
    return [(id)CFURLCopyUserName(SELF) autorelease];
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return CFGetRetainCount((CFTypeRef)self); }
- (void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PF_TODO
    return nil;
}

@end

@implementation NSURL (NSURLPathUtilities)

// TODO:
// t +[NSURL(NSURLPathUtilities) fileURLWithPathComponents:]
// t -[NSURL(NSURLPathUtilities) URLByAppendingPathComponent:]
// t -[NSURL(NSURLPathUtilities) URLByAppendingPathComponent:isDirectory:]
// t -[NSURL(NSURLPathUtilities) URLByAppendingPathExtension:]
// t -[NSURL(NSURLPathUtilities) URLByDeletingLastPathComponent]
// t -[NSURL(NSURLPathUtilities) URLByDeletingPathExtension]
// t -[NSURL(NSURLPathUtilities) URLByResolvingSymlinksInPath]
// t -[NSURL(NSURLPathUtilities) URLByStandardizingPath]
// t -[NSURL(NSURLPathUtilities) lastPathComponent]
// t -[NSURL(NSURLPathUtilities) pathComponents]
// t -[NSURL(NSURLPathUtilities) pathExtension]

@end

#undef SELF
