//
// imageloader.m
//
// Copyright (c) 2013 David Condrey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ImageLoader.h"

@implementation ImageLoader

@synthesize image;
@synthesize indexPath;
@synthesize index;

- (void) dealloc {
    [super dealloc];
    [url release];
    [connection release];
    [mutData release];
    [image release];
}

- (id)initWithURL:(NSURL *)aURL {
    url = [aURL retain];
    return self;
}

- (void) setDelegate:(id)anObject {
    delegate = anObject;
}

- (void) load {
    NSURLRequest * request = [[[NSURLRequest alloc] initWithURL:url] autorelease];

    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    mutData = [[[NSMutableData alloc] init] retain];
}

- (void) cancel {
    if (connection && delegate) {
        [connection cancel];
        [connection release];
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(imageLoader:didReceiveError:)]) {
        [delegate imageLoader:self didReceiveError:error];
    }
}

- (void) imageLoader:(ImageLoader *)loader didReceiveError:(NSError *)anError {
    NSLog(@"Hello");
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    [mutData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)aConnection {
    [connection release];

    image = [[[UIImage alloc] initWithData:mutData] retain];

    if ([delegate respondsToSelector:@selector(imageLoader:didLoadImage:)]) {
        [delegate imageLoader:self didLoadImage:image];
    }
}

@end