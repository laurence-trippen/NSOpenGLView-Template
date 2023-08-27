//
//  LLTOpenGLVIew.m
//  NSOpenGLViewTest
//
//  Created by Laurence Trippen on 26.08.23.
//

#import "LLTOpenGLView.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>


static CVReturn GlobalDisplayLinkCallback(CVDisplayLinkRef,
                                          const CVTimeStamp*,
                                          const CVTimeStamp*,
                                          CVOptionFlags,
                                          CVOptionFlags*, void*);


@implementation LLTOpenGLView

#pragma mark - Initializers


- (id) initWithFrame: (NSRect) frameRect {
  // NSOpenGLPixelFormat* pixelFormat = [NSOpenGLView defaultPixelFormat];
  
  windowRect = frameRect;
  
  running = true;
  
  int samples = 0;
  
  // Keep multisampling attributes at the start of the attribute lists since code below assumes they are array elements 0 through 4.
  NSOpenGLPixelFormatAttribute windowedAttrs[] =
  {
    NSOpenGLPFAMultisample,
    NSOpenGLPFASampleBuffers, samples ? 1 : 0,
    NSOpenGLPFASamples, samples,
    NSOpenGLPFAAccelerated,
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAColorSize, 32,
    NSOpenGLPFADepthSize, 24,
    NSOpenGLPFAAlphaSize, 8,
    NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy,
    0
  };
  
  // Try to choose a supported pixel format
  NSOpenGLPixelFormat* pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:windowedAttrs];
  
  if (!pf) {
    bool valid = false;
    while (!pf && samples > 0) {
      samples /= 2;
      windowedAttrs[2] = samples ? 1 : 0;
      windowedAttrs[4] = samples;
      pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:windowedAttrs];
      if (pf) {
        valid = true;
        break;
      }
    }
    
    if (!valid) {
      NSLog(@"OpenGL pixel format not supported.");
      return nil;
    }
  }
  
  self = [super initWithFrame: frameRect pixelFormat: pf];
  
  return self;
}


#pragma mark - NSOpenGLView Delegate


- (void) prepareOpenGL {
  [super prepareOpenGL];
  
  // Make all the OpenGL calls to setup rendering and build the necessary rendering objects
  [[self openGLContext] makeCurrentContext];
  
  // Synchronize buffer swaps with vertical refresh rate
  GLint swapInt = 1; // Vsynch on!
  [[self openGLContext] setValues: &swapInt forParameter: NSOpenGLCPSwapInterval];
  
  // Create a display link capable of being used with all active displays
  CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
  
  // Set the renderer output callback function
  CVDisplayLinkSetOutputCallback(displayLink, &GlobalDisplayLinkCallback, (__bridge void * _Nullable)(self));
  
  CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
  CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
  CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
  
  GLint dim[2] = {windowRect.size.width, windowRect.size.height};
  CGLSetParameter(cglContext, kCGLCPSurfaceBackingSize, dim);
  CGLEnable(cglContext, kCGLCESurfaceBackingSize);
  
  CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
  NSLog(@"Initialize");
  
  glClearColor(0.5f, 0.6f, 0.7f, 1.0f);
  glViewport(0, 0, windowRect.size.width, windowRect.size.height);
  glEnable(GL_DEPTH_TEST);
  
  CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
  
  // Activate the display link
  CVDisplayLinkStart(displayLink);
}


- (void) reshape {
  [super reshape];  // Call the superclass's reshape method

  NSLog(@"Reshape");
  
  self.frame = self.window.contentView.frame;
  
  // Get the new dimensions of the view
  NSRect frame = [self bounds];
  GLint width = frame.size.width;
  GLint height = frame.size.height;

  // Update the OpenGL viewport
  glViewport(0, 0, width, height);
}


#pragma mark - Window Delegate

/*
- (void) windowDidResize:(NSNotification *)notification {
  NSLog(@"Resize");
  
  NSSize size = self.window.contentView.frame.size;
  
  if (size.width == 0 || size.height == 0) return;
  
  self.frame = self.window.contentView.frame;
  
  [[self openGLContext] makeCurrentContext];
  
  CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
  
  NSLog(@"Window resize: %lf, %lf", size.width, size.height);
  
  // Temp
  windowRect.size.width = size.width;
  windowRect.size.height = size.height;
  
  // glViewport(0, 0, windowRect.size.width, windowRect.size.height);
  // End temp
  
  CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}
*/


#pragma mark - Methods


// Update
- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime {
  [[self openGLContext] makeCurrentContext];
  CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  
  // Draw here ...
  glColor3f(1.0f, 0.85f, 0.35f);
  glBegin(GL_TRIANGLES);
  
      glVertex3f(  0.0,  0.6, 0.0);
      glVertex3f( -0.2, -0.3, 0.0);
      glVertex3f(  0.2, -0.3 ,0.0);
  
  glEnd();
  
  // Draw End

  CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
  CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);

  // TODO: Implement quit
  if (false) { // Update loop returns false
    [NSApp terminate:self];
  }
  
  return kCVReturnSuccess;
}

@end


static CVReturn GlobalDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
  CVReturn result = [(__bridge LLTOpenGLView*)displayLinkContext getFrameForTime:outputTime];
  return result;
}

