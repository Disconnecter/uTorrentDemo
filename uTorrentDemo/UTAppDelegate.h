//
//  UTAppDelegate.h
//  uTorrentDemo
//
//  Created by Zabolotnyy Sergey on 2/5/13.
//  Copyright (c) 2013 Zabolotnyy Sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UTBackend.h"

@interface UTAppDelegate : UIResponder <UIApplicationDelegate, UTBackendDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
