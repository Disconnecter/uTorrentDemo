//
//  UTTorrent.h
//  uTorrentDemo
//
//  Created by Zabolotnyy Sergey on 2/27/13.
//  Copyright (c) 2013 Zabolotnyy Sergey. All rights reserved.
//

/*
HASH (string),
STATUS* (integer),
NAME (string),
SIZE (integer in bytes),
PERCENT PROGRESS (integer in per mils),
DOWNLOADED (integer in bytes),
UPLOADED (integer in bytes),
RATIO (integer in per mils),
UPLOAD SPEED (integer in bytes per second),
DOWNLOAD SPEED (integer in bytes per second),
ETA (integer in seconds),
LABEL (string),
PEERS CONNECTED (integer),
PEERS IN SWARM (integer),
SEEDS CONNECTED (integer),
SEEDS IN SWARM (integer),
AVAILABILITY (integer in 1/65535ths),
TORRENT QUEUE ORDER (integer),
REMAINING (integer in byte
*/

#import <Foundation/Foundation.h>

@interface UTTorrent : NSObject

@property (retain,nonatomic) NSString *hash;
@property (assign,nonatomic) NSInteger status;
@property (retain,nonatomic) NSString *name;
@property (assign,nonatomic) NSInteger size;
@property (assign,nonatomic) NSInteger percentProgress;
@property (assign,nonatomic) NSInteger downloaded;
@property (assign,nonatomic) NSInteger uploaded;
@property (assign,nonatomic) NSInteger ratio;
@property (assign,nonatomic) NSInteger uploadSpeed;
@property (assign,nonatomic) NSInteger downloadSpeed;
@property (assign,nonatomic) NSInteger eta;
@property (retain,nonatomic) NSString *label;
@property (assign,nonatomic) NSInteger peersConnected;
@property (assign,nonatomic) NSInteger peersInSwarm;
@property (assign,nonatomic) NSInteger seedsConnected;
@property (assign,nonatomic) NSInteger seedsInSwarm;
@property (assign,nonatomic) NSInteger availability;
@property (assign,nonatomic) NSInteger torrentQueueOrder;
@property (assign,nonatomic) NSInteger remaining;

+(UTTorrent *) torrentWithArray:(NSArray *)torrentArray;

@end
