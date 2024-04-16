//
//  ExifDataConverter.h
//  ExifTools
//
//  Created by tbago on 2020/5/25.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExifData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExifDataConverter : NSObject

+ (void)converterExifDataToReadable:(NSArray<ExifData *> *) exifDataArray;

@end

NS_ASSUME_NONNULL_END
