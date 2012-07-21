
//
// Copyright 2011 Box, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "BoxNetworkOperation.h"


@interface BoxNetworkOperation()

@property (nonatomic, readwrite, retain) NSURLConnection * connection;
@property (nonatomic, retain) NSHTTPURLResponse * networkResponse;
@property (nonatomic, retain) NSMutableData * receivedData;

@end

@implementation BoxNetworkOperation

@synthesize expectedContentLength = _expectedContentLength;
@synthesize path = _path;
@synthesize completionRatio = _completionRatio;
@synthesize displayInUI = _displayInUI;
@synthesize recordReceivedData = _recordReceivedData;
@dynamic summary;
@synthesize connection = __connection;
@synthesize networkResponse = _networkResponse;
@synthesize receivedData = _receivedData;

#pragma mark -
#pragma mark Initialization

- (id)initForType:(BoxOperationType)type delegate:(id <BoxOperationDelegate>)delegate {
	return [self initForType:type delegate:delegate path:nil];
}

- (id)initForType:(BoxOperationType)type delegate:(id <BoxOperationDelegate>)delegate path:(NSString *)path {
	if (self = [super initForType:type delegate:delegate]) {
		_uniqueID = nil;
		_isExecuting = NO;
		_isFinished = NO;
		_networkResponse = nil;
		_receivedData = nil;
        __connection = nil;
		_displayInUI = YES;
		_recordReceivedData = YES;

		self.completionRatio = [NSNumber numberWithFloat:0.0];
		self.path = path;
		self.summary = @"Performing unknown network operation…";
		[self addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"isCancelled"];
    self.path = nil;
    self.completionRatio = nil;
    
    [__connection release];
    __connection = nil;
    [_networkResponse release];
    _networkResponse = nil;
    
    [_receivedData release];
    _receivedData = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark NSOperation methods

- (void)start {
	if (![self isCancelled] && ![[[self dependencies] lastObject] isCancelled]) {
		NSURLRequest *request = [self URLRequest];
		if (request) {
			[self willChangeValueForKey:@"isExecuting"];
			_isExecuting = YES;
			[self didChangeValueForKey:@"isExecuting"];

			if ([_delegate respondsToSelector:@selector(operation:willBeginForPath:)]) {
				[_delegate operation:self willBeginForPath:_path];
			}
            
			self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
			_receivedDataLength = 0;
			if (_recordReceivedData) {
				_receivedData = [[NSMutableData alloc] init];
			}
			if (self.connection == nil) {
				[self finish];
			}
		} else {
			[self finish];
		}
	} else {
		[self finish];
	}
	
	CFRunLoopRun();
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([self isCancelled]) {
		[self.connection cancel];
		[self setResponseType:BoxOperationResponseUserCancelled];
		[self finish];
	}
}

- (NSURL *)url {
	return nil;
}

- (NSURLRequest *)URLRequest {
	NSURL *url = [self url];
	if (url) {
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[self url]];
		[request setHTTPShouldHandleCookies:NO];
		[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
		return [request autorelease];
	}

	return nil;
}

- (NSString *)uniqueID {
	if (!_uniqueID) {
		CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
		CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
		_uniqueID = [[NSString stringWithString:(NSString*)strRef] retain];
		CFRelease(strRef);
		CFRelease(uuidRef);
	}

	return _uniqueID;
}

- (void)finish {	
	[__connection release];
    __connection = nil;

	[self willChangeValueForKey:@"isExecuting"];
	_isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];

	[self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
	[self didChangeValueForKey:@"isFinished"];

	CFRunLoopStop(CFRunLoopGetCurrent());
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

#pragma mark Subclass Overrides

- (void)requestDidProgressWithRatio:(NSNumber *)ratio {
	if ([_delegate respondsToSelector:@selector(operation:didProgressForPath:completionRatio:)]) {
		[_delegate operation:self didProgressForPath:_path completionRatio:ratio];
	}
}

- (void)requestDidCompleteWithResponse:(NSHTTPURLResponse *)response {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([_delegate respondsToSelector:@selector(operation:didCompleteForPath:response:)]) {
		[_delegate operation:self didCompleteForPath:_path response:_operationResponse];
	}
	[pool drain];
	
	[self finish];
}

- (void)requestDidFailWithError:(NSError *)error {
	if (error) {
		[self setResponseType:BoxOperationResponseUnknownError];
		self.error = error;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([_delegate respondsToSelector:@selector(operation:didCompleteForPath:response:)]) {
		[_delegate operation:self didCompleteForPath:_path response:_operationResponse];
	}
	[pool drain];
	
	[self finish];
}


#pragma mark Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	self.networkResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//BOXLog(@"CONNECTION GOT DATA");

	_receivedDataLength += [data length];
	if (self.receivedData) {
        @synchronized(self.receivedData) {
            [self.receivedData appendData:data];
        }
	}

	if ([self.networkResponse expectedContentLength] > 0) {
		//BOXLog(@"Received data of length: %d expected: %d", [_receivedData length], [self.networkResponse expectedContentLength]);
		self.expectedContentLength = [self.networkResponse expectedContentLength];
		self.completionRatio = [NSNumber numberWithDouble:(double)_receivedDataLength/(double)self.expectedContentLength];
		[self requestDidProgressWithRatio:self.completionRatio];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//BOXLog(@"CONNECTION FINISHED");

	if ([self.networkResponse expectedContentLength] > 0) {
		self.completionRatio = [NSNumber numberWithDouble:1.0];
		[self requestDidProgressWithRatio:self.completionRatio];
	}

	[self requestDidCompleteWithResponse:self.networkResponse];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	//BOXLog(@"Sent percentage: %f of length: %d expected: %d", (double)totalBytesWritten/(double)totalBytesExpectedToWrite, totalBytesWritten, totalBytesExpectedToWrite);

	if (totalBytesExpectedToWrite > 0) {
		// Throttle progress update notifications on a percentage basis
		// This will reduce CPU usage and make for smoother progress bars
		double newRatio = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
		if (floor(newRatio*100.0) != floor([self.completionRatio doubleValue]*100.0)) {
			self.completionRatio = [NSNumber numberWithDouble:newRatio];
			[self requestDidProgressWithRatio:self.completionRatio];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//BOXLog(@"CONNECTION GOT ERROR");
	[self requestDidFailWithError:error];
}

#pragma mark Observation

+ (NSSet *)keyPathsForValuesAffectingObservableDetails {
    return [NSSet setWithObjects:@"uniqueID", @"displayInUI", @"path", @"isFinished", @"isExecuting", @"completionRatio", @"summary", nil];
}

- (NSObject *)observableDetails {
	NSMutableDictionary *details = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									self.uniqueID, @"uniqueID",
									[NSNumber numberWithBool:self.displayInUI], @"displayInUI",
									[NSNumber numberWithBool:self.isFinished], @"isFinished",
									[NSNumber numberWithBool:self.isExecuting], @"isExecuting",
									self.completionRatio, @"completionRatio", nil];

	if (self.path) {
		[details setObject:self.path forKey:@"path"];
	}

	if (self.summary) {
		[details setObject:self.summary forKey:@"summary"];
	}

	return details;
}

@end
