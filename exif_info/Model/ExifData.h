//
//  ExifData.h
//  ExifTools
//
//  Created by tbago on 2020/5/22.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExifData : NSObject

@property (copy, nonatomic) NSString    *dataName;
@property (copy, nonatomic) NSString    *dataDescription;
@property (copy, nonatomic) NSString    *dataValue;

+ (instancetype)initWithOriginName:(const char *) originName
                       originValue:(const char *) originValue;

@end

NS_ASSUME_NONNULL_END
