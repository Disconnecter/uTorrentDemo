//
//  UTBackend.h
//  uTorrentDemo
//
//  Created by Zabolotnyy Sergey on 2/5/13.
//  Copyright (c) 2013 Zabolotnyy Sergey. All rights reserved.
//

/*
* Most action commands require a hash to be passed. 
* This is the infohash of the torrent, obtained from listing all torrents.
* Each hash is a 40-character ASCII string. Some commands accept multiple infohashes chained together,
* e.g. http://[IP]:[PORT]/gui/?action=[ACTION]&hash=[TORRENT HASH 1]&hash=[TORRENT HASH 2]&...
* to cut down on the number of requests required.
*/

@protocol UTBackendDelegate;

typedef enum
{
    UTTorrentDefaultAction,
    /*To get the list of files in a torrent job*/
    UTTorrentGetfiles,
    /*This action tells µTorrent to start the specified torrent job(s)*/
    UTTorrentStart,
    /*This action tells µTorrent to stop the specified torrent job(s)*/
    UTTorrentStop,
    /*This action tells µTorrent to pause the specified torrent job(s)*/
    UTTorrentPause,
    /*This action tells µTorrent to force the specified torrent job(s) to start*/
    UTTorrentForcestart,
    /*This action tells µTorrent to unpause the specified torrent job(s)*/
    UTTorrentUnpause,
    /*This action tells µTorrent to recheck the torrent contents for the specified torrent job(s)*/
    UTTorrentRecheck,
    /*This action removes the specified torrent job(s) from the torrent jobs list. 
     *Multiple hashes may be specified to act on multiple torrent jobs. T
     *his action respects the option "Move to trash if possible".
     */
    UTTorrentRemove,
    /*This action removes the specified torrent job(s) from the torrent jobs list 
     *and removes the corresponding torrent contents (data) from disk.
     *Multiple hashes may be specified to act on multiple torrent jobs. This action respects the option "Move to trash if possible".
     */
    UTTorrentRemovedata,
    /*To get a list of the various properties for a torrent job*/
    UTTorrentGetprops
} UTBackendAction;

typedef enum
{
    UTBackendLoginNotLogin,
    UTBackendLoginFailed,
    UTBackendLoginSucsessed
}UTBackendLoginStatus;

@interface UTBackend : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate>

@property (nonatomic,assign)UTBackendLoginStatus loginStatus;
@property (atomic,assign) id<UTBackendDelegate>delegate;

+ (UTBackend*) sharedInstance;

- (void)setServerUrl:(NSString *)serverUrl andPort:(NSString*)port;

- (void)executeAction:(UTBackendAction)action
     forTorrentHashes:(NSArray*) torrentHashes
  withCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
        withFailBlock:(void (^)(NSError* error)) failBlock;

-(void)setSettings:(NSDictionary *) setingsValue;

- (void)addTorrentWithUrl:(NSString *)torrentUrl
      WithCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
            withFailBlock:(void (^)(NSError* error)) failBlock;

- (void)getTorentsListWithCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
                            withFailBlock:(void (^)(NSError* error)) failBlock;

@end

@protocol UTBackendDelegate <NSObject>

- (void)didloginWithStatus:(UTBackendLoginStatus)status;

@end
