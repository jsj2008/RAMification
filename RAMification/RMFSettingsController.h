//
//  SettingsToolbarDelegate.h
//  RAMification
//
//  Created by Michael Starke on 25.11.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMFGeneralSettingsController.h"
#import "RMFFavoritesSettingsController.h"

@interface RMFSettingsController : NSObject <NSToolbarDelegate> {
  @private
  NSDictionary *settingsPaneControler;
}

@property (assign) IBOutlet NSWindow *settingsWindow;

- (void) showSettings: (id)sender;

@end
