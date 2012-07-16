//
//  NSString+RMFVolumeTools.m
//  RAMification
//
//  Created by Michael Starke on 11.12.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+RMFVolumeTools.h"

@implementation NSString (RMFVolumeTools)


+ (NSString *)uniqueVolumeName:(NSString *)baseName inFolder:(NSString *)path
{
  NSString *uniqueName = [baseName retain];
  NSError *anError = nil;
  NSArray *filePaths= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&anError];
  //TODO: add error handling
  NSMutableSet *files = [NSMutableSet setWithCapacity:[filePaths count]];
  for(NSString* filePath in filePaths)
  {
    [files addObject:[filePath lastPathComponent]];
  }
  
  if([files containsObject:baseName])
  {
    // search for all matching files to our pattern
    NSPredicate *nameMatcher = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [baseName stringByAppendingString:@"_[0-9]+"]];
    [files filterUsingPredicate:nameMatcher];
    NSMutableSet *suffixes = [NSMutableSet setWithCapacity:[files count]];
    
    // gather all the numerical extensions
    for(NSString *filename in files)
    {
      NSString *suffixString = [filename stringByReplacingOccurrencesOfString:[baseName stringByAppendingString:@"_"] withString:@""];
      NSInteger suffix;
      [[NSScanner scannerWithString:suffixString] scanInteger:&suffix];
      [suffixes addObject:[NSNumber numberWithInteger:suffix]];
    }
    // Sort the numbers ascending
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"integerValue" ascending:YES]];
    NSArray *sortedSuffixed = [suffixes sortedArrayUsingDescriptors:descriptor];
    // Calculate next number based on biggest found
    // We do not try to fill holes
    NSNumber *maximum = [sortedSuffixed lastObject];
    NSNumber *nextSuffix = [NSNumber numberWithInteger:( [maximum integerValue] + 1 ) ];
    
    NSString *newName = [uniqueName stringByAppendingFormat:@"%@_", nextSuffix];
    // release retained old string as we do not need it anymore
    [uniqueName release];
    uniqueName = newName;
  }
  else {
    // Autorelease because we collected ownership
    [uniqueName autorelease];
  }
  return uniqueName;
}

- (BOOL)isUsedAsVolumeName
{
  // get all the mounted removable volumes
  NSArray *mountedMedia = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes];
  BOOL(^pathBlock)(id,NSDictionary*);
  pathBlock = ^BOOL(id evaluatedObject, NSDictionary *bindings) {
    return [[((NSURL *)evaluatedObject) lastPathComponent] isEqualToString:self];
  };
  
  NSPredicate *pathPredicate = [NSPredicate predicateWithBlock:pathBlock];
  NSArray *matchingPaths = [mountedMedia filteredArrayUsingPredicate:pathPredicate];
  // return if we are in the array (name based search)
  return ([matchingPaths count] == 0);
}

- (NSString *)volumePath
{
  return [NSString stringWithFormat:@"/Volumes/", self];
}

@end
