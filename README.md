ARAppGroupMessager
==================

A lightweight utility for sending messages between an iOS extension and an iOS application (i.e. WatchKit Extension to App). It uses app groups and their shared containers to send messages via the file system and file coordination.

Examples
---

### Sending a message from an extension
```
ARAppGroupMessager *messager = [ARAppGroupMessager messagerWithGroupIdentifier:@"group.com.myapp.exampleAppGroup" host:ARAppGroupMessagerHostExtension];

[messager sendMessage:@{ @"data" : @"messageContent" }];
```

### Receiving a message in the main application
```
ARAppGroupMessager *messager = [ARAppGroupMessager messagerWithGroupIdentifier:@"group.com.myapp.exampleAppGroup" host:ARAppGroupMessagerHostMainApplication];

[messager startMonitoringMessagesWithCallback:^(NSDictionary *payload) {
    NSString *content = payload[@"data"];
    // Do something with the content of the message
}];
```