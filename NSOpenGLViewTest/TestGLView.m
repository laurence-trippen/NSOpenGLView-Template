//
//  TestGLView.m
//  NSOpenGLViewTest
//
//  Created by Laurence Trippen on 26.08.23.
//

#import "TestGLView.h"

@implementation TestGLView

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame: frameRect pixelFormat: [NSOpenGLView defaultPixelFormat]];
  
  return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
