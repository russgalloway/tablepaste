//
//  TablePasteAppDelegate.h
//  TablePaste
//
//  Created by Russ Galloway on 4/13/11.
//  Copyright 2011 Russ Galloway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JFHotkeyManager.h"

@interface TablePasteAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) JFHotkeyManager *hotkeys;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NSImage *menuIcon;

- (IBAction)saveAction:sender;

- (void)tablePasteHotkeyHandler;
- (void)closeApp:(id)sender;

@end
