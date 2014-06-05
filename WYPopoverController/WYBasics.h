//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define WY_BASE_SDK_7_ENABLED
#endif

#ifdef DEBUG
#define WY_LOG(fmt, ...)		NSLog((@"%s (%d) : " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WY_LOG(...)
#endif

#define WY_IS_IOS_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define WY_IS_IOS_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define WY_IS_IOS_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define WY_IS_IOS_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)