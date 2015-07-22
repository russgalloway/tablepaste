//
//  TablePasteAppDelegate.m
//  TablePaste
//
//  Created by Russ Galloway on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TablePasteAppDelegate.h"

@implementation TablePasteAppDelegate

@synthesize window, hotkeys, statusItem, menuIcon;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    self.hotkeys = [[JFHotkeyManager alloc] init];
    [hotkeys bind:@"shift alt command t" target:self action:@selector(tablePasteHotkeyHandler)];
    
    self.statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setEnabled:YES];
    [self.statusItem setToolTip:[NSString stringWithFormat:@"TablePaste:\nPress %C%C%CT to paste tab delimited data as a table. \nClick this icon to quit.", 0x21E7, 0x2325, 0x2318]];
    [self.statusItem setTitle:[NSString stringWithString:@""]]; 
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"StatusItemIcon" ofType:@"png"];
    self.menuIcon = [[NSImage alloc] initWithContentsOfFile:path];    
    [self.statusItem setImage:menuIcon];    
    
    [self.statusItem setAction:@selector(closeApp:)];
    [self.statusItem setTarget:self];
}

- (void)closeApp:(id)sender
{
    [[NSApplication sharedApplication] terminate:sender];
}

- (void)tablePasteHotkeyHandler
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    NSLog(@"*** Clipboard types *** \n%@\n\n", [pb types]);
    for (NSString *pbType in [pb types]) 
    {
        NSString *stringData = [pb stringForType:pbType];
        NSLog(@"*** Clipboard Type: %@ *** \n%@\n\n", pbType, stringData);
    }

    NSString *stringData = [pb stringForType:NSStringPboardType];
    NSArray *rows = [stringData componentsSeparatedByString:@"\n"];
    NSString *htmlContent = @"<table style='border: 1px solid #CCC; border-collapse: collapse; font-family: Arial;'>";
    
    int i = 0;
    for (NSString *row in rows) 
    {
        htmlContent = [htmlContent stringByAppendingString:@"<tr>"];
        NSArray *cols = [row componentsSeparatedByString:@"\t"];
        
        for (NSString *col in cols) 
        {
            htmlContent = [htmlContent stringByAppendingString:@"<td style='padding: 5px; border: 1px solid #CCC;"];

            if (i == 0)
                htmlContent = [htmlContent stringByAppendingString:@" background-color: #EFEFEF; font-size: 12px; font-weight: bold; text-align:center;"];
            else
                htmlContent = [htmlContent stringByAppendingString:@" background-color: #FFFFFF; font-size: 12px;"];
            
            htmlContent = [htmlContent stringByAppendingFormat:@"'>%@</td>", col];
        }
        
        htmlContent = [htmlContent stringByAppendingString:@"</tr>"];        
        i++;
    }

    htmlContent = [htmlContent stringByAppendingString:@"</table>"];
    
    [pb clearContents];
    NSArray *types = [NSArray arrayWithObjects:NSHTMLPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString:htmlContent forType:NSHTMLPboardType];
    
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    CGEventRef pasteCommandDown = CGEventCreateKeyboardEvent(source, (CGKeyCode)9, YES);
    CGEventSetFlags(pasteCommandDown, kCGEventFlagMaskCommand);
    CGEventRef pasteCommandUp = CGEventCreateKeyboardEvent(source, (CGKeyCode)9, NO);
    
    CGEventPost(kCGAnnotatedSessionEventTap, pasteCommandDown);
    CGEventPost(kCGAnnotatedSessionEventTap, pasteCommandUp);
    
    CFRelease(pasteCommandUp);
    CFRelease(pasteCommandDown);
    CFRelease(source);

    // Reset pasteboard
//    [pb clearContents];
//    NSArray *types2 = [NSArray arrayWithObjects:NSStringPboardType, nil];
//    [pb declareTypes:types2 owner:self];
//    [pb setString:stringData forType:NSStringPboardType];

    NSLog(@"*** Clipboard types *** \n%@\n\n", [pb types]);
    for (NSString *pbType in [pb types]) 
    {
        NSString *stringData = [pb stringForType:pbType];
        NSLog(@"*** Clipboard Type: %@ *** \n%@\n\n", pbType, stringData);
    }
    
}


/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "TablePaste" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"TablePaste"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TablePaste" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"TablePaste.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [self.hotkeys release];
    [self.statusItem release];
    [self.menuIcon release];
    [super dealloc];
}

@end
