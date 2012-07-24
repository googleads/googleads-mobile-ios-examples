// HelloWorldLayer.h
// Copyright 2012 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "HelloWorldLayer.h"

@implementation HelloWorldLayer

+(CCScene *)scene {
  // Remember that 'scene' is an autorelease object.
  CCScene *scene = [CCScene node];
  // Remember that 'layer' is an autorelease object.
  HelloWorldLayer *layer = [HelloWorldLayer node];

  // Add layer as a child to the 'scene'.
  [scene addChild:layer];

  return scene;
}

-(id)init {
  if (self=[super init]) {
    // Since we're using kGameAutorotationUIViewController for autorotation,
    // we need to manually sign up to receive orientation change notifications
    // in this layer.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(orientationDidChange:)
               name:@"UIDeviceOrientationDidChangeNotification"
             object:nil];

    // Create and initialize a 'Hello World' Label.
    label_ = [CCLabelTTF labelWithString:@"Hello World"
                                fontName:@"Marker Felt"
                                fontSize:64];

    // Use the openGLView size instead of the window size to layout elements.
    CGSize size = [[CCDirector sharedDirector] openGLView].frame.size;
    // Position the label on the center of the screen.
    label_.position = ccp(size.width/2, size.height/2);

    // Add the label as a child to this Layer.
    [self addChild: label_];
  }
  return self;
}

-(void)orientationDidChange:(NSNotification *)notification {
  // No need to set director's orientation since we're letting UIViewController
  // handle autorotation.

  // The frame should have been updated to reflect new orientation. Re-layout
  // the label in the center.
  CGSize size = [[CCDirector sharedDirector] openGLView].frame.size;
  label_.position = ccp(size.width/2, size.height/2);
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

@end
