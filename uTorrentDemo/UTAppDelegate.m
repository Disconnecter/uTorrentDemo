//
//  UTAppDelegate.m
//  uTorrentDemo
//
//  Created by Zabolotnyy Sergey on 2/5/13.
//  Copyright (c) 2013 Zabolotnyy Sergey. All rights reserved.
//

#import "UTAppDelegate.h"
#import "UTTorrent.h"

@implementation UTAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[UTBackend sharedInstance] setServerUrl:@"tp-link340.dyndns.org" andPort:@"8081"];
    [UTBackend sharedInstance].delegate = self;
   
    return YES;
}

- (void)didloginWithStatus:(UTBackendLoginStatus)status
{
    [[UTBackend sharedInstance] getTorentsListWithCompletionBlock:^(NSDictionary *response)
    {
        NSLog(@"%@",response);

        NSArray *torrentsArr = [response objectForKey:@"torrents"];

        NSMutableArray *tempArr = [[[NSMutableArray alloc] initWithCapacity:[torrentsArr count]] autorelease];
        
        for (NSArray *torarr in torrentsArr)
        {
            [tempArr addObject:[UTTorrent torrentWithArray:torarr]];
        }
    }
                                                    withFailBlock:^(NSError *error)
    {
        NSLog(@"%@",error.localizedDescription);
    }];
    
    [[UTBackend sharedInstance] executeAction:UTTorrentGetfiles
                             forTorrentHashes:@[@"0FC867153A0B4DD832A92DF91CCE6F575AFCEE5F",@"25DA23EBFCDC9B9EBACD1AC03537523719CC2147"]
                          withCompletionBlock:^(NSDictionary *response)
    {
        NSLog(@"%@",response);
    }
                                withFailBlock:^(NSError *error)
    {
        NSLog(@"%@",error);        
    }];
}

@end
