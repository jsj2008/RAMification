//
//  SettingsToolbarDelegate.h
//  RAMification
//
//  Created by Michael Starke on 25.11.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

enum RMFSettingsTabs {
  RMFGeneralTab,
  RMFPresetsTab,
};


@interface RMFSettingsController : NSObject
{
  NSDictionary *settingsTabNames;
}

@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSView* generalTab;
@property (assign) IBOutlet NSView* presetsTab;
@property (assign) IBOutlet NSToolbar *toolbar;
@property (assign) IBOutlet NSWindow *settingsWindow;

- (IBAction) switchTabView:(id)sender;
- (void) showWindow;
- (void) intializeDefaults;

@end

APPKIT_PRIVATE_EXTERN NSString *const RMFGeneralIdentifier;
APPKIT_PRIVATE_EXTERN NSString *const RMFPresetsIdentifier;