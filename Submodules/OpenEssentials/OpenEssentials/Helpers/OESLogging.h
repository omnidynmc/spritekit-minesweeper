//
//  OESLogging.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#ifndef OpenEssentials_OESLogging_h
#define OpenEssentials_OESLogging_h

#define OESLOGGING_LEVEL_EMERGENCY   0
#define OESLOGGING_LEVEL_ALERT       1
#define OESLOGGING_LEVEL_CRITICAL    2
// don't really need the ones above but they follow RFC5424
#define OESLOGGING_LEVEL_ERROR       3
#define OESLOGGING_LEVEL_WARN        4
#define OESLOGGING_LEVEL_NOTICE      5
#define OESLOGGING_LEVEL_INFO        6
#define OESLOGGING_LEVEL_DEBUG       7

// set this to the desired level or override with CFLAGS
#ifndef OESLOGGING_LEVEL
#   define OESLOGGING_LEVEL OESLOGGING_LEVEL_DEBUG
#endif

#ifndef OESLOGGING_ENVIRONMENT_LEVEL
#   define OESLOGGING_ENVIRONMENT_LEVEL ([[[NSProcessInfo processInfo] environment] objectForKey:@"OESLoggingLevel"] == nil ? OESLOGGING_LEVEL : [[[[NSProcessInfo processInfo] environment] objectForKey:@"OESLoggingLevel"] intValue])
#endif

#define OESLOG_WITH_FORMAT(levelnum, level, fmt, ...) \
if (OESLOGGING_ENVIRONMENT_LEVEL >= levelnum) { \
    NSLog((@"%-6s: %s [Line %d] " fmt), level, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); \
}

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_EMERGENCY
#   define OESLogEmerg(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_EMERGENCY, "EMERG", fmt, ##__VA_ARGS__); \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                             reason:[NSString stringWithFormat:(@"EMERGENCY: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__] \
                                           userInfo:nil];
#else
#   define OESLogEmerg(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_ALERT
#   define OESLogAlert(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_ALERT, "ALERT", fmt, ##__VA_ARGS__);
#else
#   define OESLogAlert(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_CRITICAL
#   define OESLogCrit(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_CRITICAL, "CRIT", fmt, ##__VA_ARGS__);
#else
#   define OESLogCrit(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_ERROR
#   define OESLogError(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_ERROR, "ERROR", fmt, ##__VA_ARGS__);
#else
#   define OESLogError(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_WARN
#   define OESLogWarn(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_WARN, "WARN", fmt, ##__VA_ARGS__);
#else
#   define OESLogWarn(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_NOTICE
#   define OESLogNotice(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_NOTICE, "NOTICE", fmt, ##__VA_ARGS__);
#else
#   define OESLogNotice(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_INFO
#   define OESLogInfo(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_INFO, "INFO", fmt, ##__VA_ARGS__);
#else
#   define OESLogInfo(...)
#endif

#if defined(OESLOGGING_LEVEL) && OESLOGGING_LEVEL >= OESLOGGING_LEVEL_DEBUG
#   define OESLogDebug(fmt, ...) OESLOG_WITH_FORMAT(OESLOGGING_LEVEL_DEBUG, "DEBUG", fmt, ##__VA_ARGS__);
#else
#   define OESLogDebug(...)
#endif


#endif
