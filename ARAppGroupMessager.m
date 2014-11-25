//
//  ARAppGroupMessager.m
//
//  Created by Andy Roth on 11/19/14.
//

#import "ARAppGroupMessager.h"

static NSString * const kARAppGroupMessagerKeyHost              = @"host";
static NSString * const kARAppGroupMessagerKeyPayload           = @"payload";

@interface ARAppGroupMessager () <NSFilePresenter>

@property (nonatomic, strong) NSString *groupIdentifier;
@property (nonatomic, assign) ARAppGroupMessagerHost host;
@property (nonatomic, copy) ARAppGroupMessagerCallback callback;
@property (nonatomic, assign) BOOL monitoring;

@end

@implementation ARAppGroupMessager

#pragma mark - Initialization

+ (instancetype)messagerWithGroupIdentifier:(NSString *)identifer host:(ARAppGroupMessagerHost)host {
    ARAppGroupMessager *messager = [[ARAppGroupMessager alloc] init];
    messager.groupIdentifier = identifer;
    messager.host = host;
    
    return messager;
}

#pragma mark - Monitoring

- (void)startMonitoringMessagesWithCallback:(ARAppGroupMessagerCallback)callback {
    self.callback = callback;
    self.monitoring = YES;
    
    NSURL *fileURL = [self urlForMessageFile];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[self urlForMessageDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
        [@{ } writeToURL:fileURL atomically:YES];
    }
    
    [NSFileCoordinator addFilePresenter:self];
}

- (void)stopMonitoring {
    self.callback = nil;
    [NSFileCoordinator removeFilePresenter:self];
}

#pragma mark - Helpers

- (NSURL *)urlForMessageFile {
    NSURL *directoryURL = [self urlForMessageDirectory];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:@"ar_group_messager_messages.plist"];
    return fileURL;
}

- (NSURL *)urlForMessageDirectory {
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:self.groupIdentifier];
    NSURL *directoryURL = [containerURL URLByAppendingPathComponent:@"Messages" isDirectory:YES];
    return directoryURL;
}

#pragma mark - File Presenter

- (NSURL *)presentedItemURL {
    return self.urlForMessageFile;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange {
    __block NSDictionary *info = nil;
    
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    [coordinator coordinateReadingItemAtURL:[self urlForMessageFile] options:NSFileCoordinatorReadingWithoutChanges error:nil byAccessor:^(NSURL *newURL) {
        info = [[NSDictionary alloc] initWithContentsOfURL:newURL];
    }];
    
    ARAppGroupMessagerHost messageHost = ((NSNumber *)info[kARAppGroupMessagerKeyHost]).unsignedIntegerValue;
    if (messageHost != self.host && self.callback != nil) {
        self.callback(info[kARAppGroupMessagerKeyPayload]);
    }
}

#pragma mark - Writing

- (void)sendMessage:(NSDictionary *)message {
    if (!self.monitoring) [self startMonitoringMessagesWithCallback:nil];
    
    NSDictionary *fullMessage = @{ kARAppGroupMessagerKeyHost : @(self.host), kARAppGroupMessagerKeyPayload : message };
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    [coordinator coordinateWritingItemAtURL:[self urlForMessageFile] options:NSFileCoordinatorWritingForReplacing error:nil byAccessor:^(NSURL *newURL) {
        [fullMessage writeToURL:newURL atomically:YES];
    }];
}

@end
