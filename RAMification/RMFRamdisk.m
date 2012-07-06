//
//  RMFPresets.m
//  RAMification
//
//  Created by Michael Starke on 27.11.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import "RMFRamdisk.h"
#import "RMFAppDelegate.h"
#import "RMFSettingsKeys.h"
#import "RMFSyncDaemon.h"

// NSCodingKeys
NSString *const RMFKeyForLabel = @"label";
NSString *const RMFKeyForAutomount = @"automount";
NSString *const RMFKeyForSize = @"size";

@interface RMFRamdisk ()

@property (readwrite) BOOL isDirty;

- (void) setLabel:(NSString *)label;
- (void) setSize:(NSUInteger)size;
- (void) setIsMounted:(BOOL)isMounted;
- (void) setIsBackupEnabled:(BOOL)isBackupEnabled;

@end


@implementation RMFRamdisk

@synthesize size = _size;
@synthesize label = _label;
@synthesize devicePath;
@synthesize isAutomount;
@synthesize isMounted = _isMounted;
@synthesize isBackupEnabled = _isBackupEnabled;
@synthesize isDirty = _isDirty;

#pragma mark convinent object creation

+ (RMFRamdisk *) volumePresetWithLable:(NSString *)aLabel andSize:(NSUInteger)aSize shouldAutoMount:(BOOL)mount
{
  return [[[RMFRamdisk alloc] initWithLabel:aLabel andSize:aSize shouldMount:mount] autorelease];
}

+ (RMFRamdisk *) volumePreset
{
  return [[[RMFRamdisk alloc] init] autorelease];
}

+ (RMFRamdisk *)volumePresetWithData:(NSData *)data
{
  return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark defaults

+ (NSString *)defaultLabel
{
  return [[NSUserDefaults standardUserDefaults] stringForKey:RMFSettingsKeyLabel];
}

+ (NSUInteger)defaultSize
{
  return [[NSUserDefaults standardUserDefaults] integerForKey:RMFSettingsKeySize];
}


#pragma mark object lifecycle

- (id)init
{
  return [self initWithLabel:[RMFRamdisk defaultLabel] andSize:[RMFRamdisk defaultSize] shouldMount:NO];
}

- (id)initWithLabel:(NSString *)aLable andSize:(NSUInteger)aSize shouldMount:(BOOL)mount{
  self = [super init];
  if (self)
  {
    self.size = aSize;
    if(aLable != nil)
    {
      self.label = aLable;
    }
    else
    {
      self.label = [RMFRamdisk defaultLabel];
    } 
    self.isAutomount = mount;
    self.isMounted = NO;
  }
  return self;
}

- (void)dealloc
{
  RMFAppDelegate *delegate = [NSApp delegate];
  [delegate.syncDaemon disableBackupForRamdisk:self];
  [super dealloc];
}

#pragma mark NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if([aDecoder isKindOfClass:[NSKeyedUnarchiver class]])
  {
    self = [[RMFRamdisk alloc] init];
    self.label = [aDecoder decodeObjectForKey:RMFKeyForLabel];
    self.isAutomount = [aDecoder decodeBoolForKey:RMFKeyForAutomount];
    self.size = [aDecoder decodeIntegerForKey:RMFKeyForSize];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if([aCoder isKindOfClass:[NSKeyedArchiver class]])
  {
    //[super encodeWithCoder:aCoder];
    [aCoder encodeBool:self.isAutomount forKey:RMFKeyForAutomount];
    [aCoder encodeInteger:self.size forKey:RMFKeyForSize];
    [aCoder encodeObject:self.label forKey:RMFKeyForLabel];
  }
}

- (void) setLabel:(NSString *)label
{
  if( self.label  != label )
  {
    [_label release];
    _label = [label retain];
    // If we are mounted we are dirty,
    // otherwise we just stay the way we were
    self.isDirty |= self.isMounted;
  }
}

- (void) setSize:(NSUInteger)size
{
  if( self.size != size )
  {
    _size = size;
    // Only get dirty if mounted
    // Otherwise keep dirty state
    self.isDirty |= self.isMounted;
  }
}

- (void) setIsMounted:(BOOL)isMounted
{
  if( self.isMounted != isMounted )
  {
    self.isMounted = isMounted;
    // Mounting clears the dirty flag
    self.isDirty &= self.isMounted;
  }
}

- (void)setIsBackupEnabled:(BOOL)isBackupEnabled {
  if( self.isBackupEnabled != isBackupEnabled ) {
    _isBackupEnabled = isBackupEnabled;
    RMFAppDelegate *delegate = [NSApp delegate];
    if(self.isBackupEnabled) {
      [delegate.syncDaemon enableBackupForRamdisk:self];
    }
    else
    {
      [delegate.syncDaemon disableBackupForRamdisk:self];
    }
  }
}

- (BOOL)isEqual:(id)object
{
  BOOL isEqual = NO;
  
  if([object isMemberOfClass:[RMFRamdisk class]])
  {
    RMFRamdisk* other = (RMFRamdisk*)object;
    isEqual = [self.label isEqualToString:other.label];
    isEqual &= ( self.size == other.size );
  }
  return isEqual;
}

@end
