//
//  UTBackend.m
//  uTorrentDemo
//
//  Created by Zabolotnyy Sergey on 2/5/13.
//  Copyright (c) 2013 Zabolotnyy Sergey. All rights reserved.
//

#import "UTBackend.h"
#import "AFNetworking.h"

@implementation UTBackend

static UTBackend* instance = nil;

BOOL _authed;
NSMutableData *htmldata;
NSURLConnection *tokenConnection;
NSString *token;
NSString *curelem;
NSString *userName;
NSString *userPassword;
NSString *server;
NSString *serverPort;

+ (UTBackend*) sharedInstance
{
    if(instance == nil)
    {
        instance = [[UTBackend alloc] init];
        htmldata = [NSMutableData new];
        instance.loginStatus = UTBackendLoginNotLogin;
    }
    
    return instance;
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code == -1012)
    {
        self.loginStatus = UTBackendLoginFailed;

        if ([_delegate respondsToSelector:@selector(didloginWithStatus:)])
        {
            [_delegate didloginWithStatus:_loginStatus];
        }
    }
}

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0)
    {
        _authed = YES;
        [challenge.sender useCredential:[[[NSURLCredential alloc] initWithUser:userName
                                                                     password:userPassword
                                                                  persistence:NSURLCredentialPersistencePermanent] autorelease]
             forAuthenticationChallenge:challenge] ;
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ([connection isEqual:tokenConnection])
    {
        [htmldata appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([connection isEqual:tokenConnection])
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:htmldata];
        parser.delegate = self;
        [parser parse];
    }
}

#pragma mark - NSXMLParser delegate

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    curelem = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([curelem isEqualToString:@"div"])
    {
        token = [[NSString stringWithString:string] retain];
        
        NSLog(@"token %@",token);
        
        self.loginStatus = UTBackendLoginSucsessed;
        
        if ([_delegate respondsToSelector:@selector(didloginWithStatus:)])
        {
            [_delegate didloginWithStatus:_loginStatus];
        }
	}
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        userName = [[NSString stringWithString:[alertView textFieldAtIndex:0].text]retain];
        userPassword = [[NSString stringWithString:[alertView textFieldAtIndex:1].text]retain];
        
        tokenConnection = [[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self tokenUrl]]]
                                                           delegate:self
                                                   startImmediately:YES] autorelease];
    }
}

#pragma mark - Public methods

- (void)setServerUrl:(NSString *)serverUrl andPort:(NSString*)port
{
    server = [[serverUrl copy] retain];
    serverPort = [[port copy] retain];
    UIAlertView *alert = [UIAlertView new];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [alert setTitle:NSLocalizedString(@"Login", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Ok", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    [alert setDelegate:self];
    [alert show];
}

- (void)getTorentsListWithCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
                            withFailBlock:(void (^)(NSError* error)) failBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@?list=1&token=%@", [self serverUrl], token];
    
    [self startRequestWithUrlString:urlString
                withCompletionBlock:completionBlock
                      withFailBlock:failBlock];
}

- (void)executeAction:(UTBackendAction)action
     forTorrentHashes:(NSArray*) torrentHashes
  withCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
        withFailBlock:(void (^)(NSError* error)) failBlock
{
    NSString *actionString = nil;
    
    switch (action)
    {
        case UTTorrentGetfiles:
            actionString = @"getfiles";
            break;
        case UTTorrentStart:
            actionString = @"start";
            break;
        case UTTorrentStop:
            actionString = @"stop";
            break;
        case UTTorrentPause:
            actionString = @"pause";
            break;
        case UTTorrentForcestart:
            actionString = @"forcestart";
            break;
        case UTTorrentUnpause:
            actionString = @"unpause";
            break;
        case UTTorrentRecheck:
            actionString = @"recheck";
            break;
        case UTTorrentRemove:
            actionString = @"remove";
            break;
        case UTTorrentRemovedata:
            actionString = @"removedata";
            break;
        case UTTorrentGetprops:
            actionString = @"getprops";
            break;
        default:
            return;
            break;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?action=%@%@&token=%@", [self serverUrl], actionString, [self fullHashesString:torrentHashes],token];
    
    [self startRequestWithUrlString:urlString
                withCompletionBlock:completionBlock
                      withFailBlock:failBlock];
}

- (void)addTorrentWithUrl:(NSString *)torrentUrl
      WithCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
            withFailBlock:(void (^)(NSError* error)) failBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@?action=add-url&s=%@&token=%@", [self serverUrl], torrentUrl,token];
    
    [self startRequestWithUrlString:urlString
                withCompletionBlock:completionBlock
                      withFailBlock:failBlock];
}

-(void)setSettings:(NSDictionary *) settingsValue
{
    NSString *urlString = [NSString stringWithFormat:@"%@?action=setsetting%@&token=%@",
                           [self serverUrl],
                           [self fullSettingsString:[settingsValue allKeys]
                                          forValues:[settingsValue allValues]],
                           token];
    
    [self startRequestWithUrlString:urlString
                withCompletionBlock:nil
                      withFailBlock:nil];
}

#pragma mark - Private methods

- (NSString *)fullSettingsString:(NSArray *)settingsStrings forValues:(NSArray *)valuesStrings
{
    NSString *settingsString = nil;
    
    for (NSInteger i = 0; i < [settingsStrings count]; ++i)
    {
        settingsString = [NSString stringWithFormat:@"%@&s=%@&v=%@",settingsString,[settingsStrings objectAtIndex:i], [valuesStrings objectAtIndex:i]];
    }
    
    return settingsString;
}

- (NSString *)fullHashesString:(NSArray *)hashes
{
    NSString *hashesString = @"";
    
    for (NSString *hash in hashes)
    {
        hashesString = [NSString stringWithFormat:@"%@&hash=%@",hashesString,hash];
    }
    
    return hashesString;
}

- (NSString *)serverUrl
{
    return [NSString stringWithFormat:@"http://%@:%@/gui/",server,serverPort];
}

- (NSString *)tokenUrl
{
    return [NSString stringWithFormat:@"%@token.html", [self serverUrl]];
}

- (void)perfomRequest:(NSURLRequest *)requestURL
  withCompletionBlock:(void (^)(id response)) completionBlock
            failBlock:(void (^)(NSError *error)) failBlock
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html", nil]];
    AFJSONRequestOperation *requestOperation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         NSDictionary *responseDictionary = [NSDictionary dictionaryWithDictionary:JSON];
         
         if (((NSString *)[responseDictionary objectForKey:@"build"]).intValue > 0)
         {
             if ( completionBlock )
                 completionBlock(responseDictionary);
         }
         else
         {
             NSError* error = [NSError errorWithDomain:@"ErrorDomain"
                                                  code:-1
                                              userInfo:
                               [NSDictionary dictionaryWithObject:[responseDictionary objectForKey:@"error"]
                                                           forKey:NSLocalizedDescriptionKey]];
             if(failBlock)
                 failBlock(error);
         }
     }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         if(failBlock)
             failBlock(error);
     }];
    
    [requestOperation start];
}

- (void)startRequestWithUrlString:(NSString *) urlString
              withCompletionBlock:(void (^)(NSDictionary* response)) completionBlock
                    withFailBlock:(void (^)(NSError* error)) failBlock

{
    NSString *stringURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self perfomRequest:requestURL
    withCompletionBlock:^(NSDictionary *response)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if ( completionBlock )
             completionBlock(response);
     }
              failBlock:^(NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if(failBlock)
             failBlock(error);
     }];
}

@end
