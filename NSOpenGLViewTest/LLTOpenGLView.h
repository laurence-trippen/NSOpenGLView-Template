//
//  LLTOpenGLVIew.h
//  NSOpenGLViewTest
//
//  Created by Laurence Trippen on 26.08.23.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLTOpenGLView : NSOpenGLView <NSWindowDelegate> {
  CVDisplayLinkRef displayLink;
  bool running;
  NSRect windowRect;
}

@end

NS_ASSUME_NONNULL_END
