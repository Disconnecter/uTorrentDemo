//
//  UTTorrent.m
//  uTorrentDemo
//
//  Created by Zabolotnyy Sergey on 2/27/13.
//  Copyright (c) 2013 Zabolotnyy Sergey. All rights reserved.
//

#import "UTTorrent.h"

@implementation UTTorrent

+(UTTorrent *) torrentWithArray:(NSArray *)torrentArray
{
    return [[[UTTorrent alloc] initWithArray:torrentArray] autorelease];;
}

-(id)initWithArray:(NSArray *)torrentArray
{
    self = [super init];
    
    if (self)
    {
        self.hash               = [torrentArray objectAtIndex:0];
        self.status             = ((NSNumber*)[torrentArray objectAtIndex:1]).integerValue;
        self.name               = [torrentArray objectAtIndex:2];
        self.size               = ((NSNumber*)[torrentArray objectAtIndex:3]).integerValue;
        self.percentProgress    = ((NSNumber*)[torrentArray objectAtIndex:4]).integerValue;
        self.downloaded         = ((NSNumber*)[torrentArray objectAtIndex:5]).integerValue;
        self.uploaded           = ((NSNumber*)[torrentArray objectAtIndex:6]).integerValue;
        self.ratio              = ((NSNumber*)[torrentArray objectAtIndex:7]).integerValue;
        self.uploadSpeed        = ((NSNumber*)[torrentArray objectAtIndex:8]).integerValue;
        self.downloadSpeed      = ((NSNumber*)[torrentArray objectAtIndex:9]).integerValue;
        self.eta                = ((NSNumber*)[torrentArray objectAtIndex:10]).integerValue;
        self.label              = [torrentArray objectAtIndex:11];
        self.peersConnected     = ((NSNumber*)[torrentArray objectAtIndex:12]).integerValue;
        self.peersInSwarm       = ((NSNumber*)[torrentArray objectAtIndex:13]).integerValue;
        self.seedsConnected     = ((NSNumber*)[torrentArray objectAtIndex:14]).integerValue;
        self.seedsInSwarm       = ((NSNumber*)[torrentArray objectAtIndex:15]).integerValue;
        self.availability       = ((NSNumber*)[torrentArray objectAtIndex:16]).integerValue;
        self.torrentQueueOrder  = ((NSNumber*)[torrentArray objectAtIndex:17]).integerValue;
        self.remaining          = ((NSNumber*)[torrentArray objectAtIndex:18]).integerValue;
    }

    return self;
}

@end
