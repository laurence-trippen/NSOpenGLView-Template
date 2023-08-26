//
//  ViewController.m
//  NSOpenGLViewTest
//
//  Created by Laurence Trippen on 26.08.23.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSWindow* mainWindow = [NSApplication sharedApplication].windows.firstObject;
  
  _glView = [[LLTOpenGLView alloc] initWithFrame: self.view.bounds];
  
  [mainWindow setDelegate: _glView];
  
  [self.view addSubview: _glView];
}

@end
