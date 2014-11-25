//
//  ARAppGroupMessager.h
//
//  Created by Andy Roth on 11/19/14.
//

#import <Foundation/Foundation.h>

typedef void(^ARAppGroupMessagerCallback)(NSDictionary *payload);

typedef NS_ENUM(NSUInteger, ARAppGroupMessagerHost) {
    ARAppGroupMessagerHostMainApplication,
    ARAppGroupMessagerHostExtension
};

@interface ARAppGroupMessager : NSObject

+ (instancetype)messagerWithGroupIdentifier:(NSString *)identifer host:(ARAppGroupMessagerHost)host;

- (void)startMonitoringMessagesWithCallback:(ARAppGroupMessagerCallback)callback;
- (void)stopMonitoring;

- (void)sendMessage:(NSDictionary *)message;

@end
