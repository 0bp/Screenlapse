//
//  AppDelegate.h
//  Screenlapse
//

#import <Cocoa/Cocoa.h>
#import "WindowListDataSource.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
  WindowListDataSource * windowListDS;
  NSArray * selectedApplications;
  NSTimer * interval;
  BOOL capturing;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *WindowList;
@property (weak) IBOutlet NSImageView *previewView;
@property (weak) IBOutlet NSButton *captureButton;
@property (weak) IBOutlet NSTableView *windowTableView;
@property (weak) IBOutlet NSButton *reloadButton;

@property (weak) IBOutlet NSMenuItem *Interval_1;
@property (weak) IBOutlet NSMenuItem *Interval_5;
@property (weak) IBOutlet NSMenuItem *Interval_10;
@property (weak) IBOutlet NSMenuItem *Interval_15;
@property (weak) IBOutlet NSMenuItem *Interval_20;
@property (weak) IBOutlet NSMenuItem *Interval_30;
@property (weak) IBOutlet NSMenuItem *Interval_60;

- (NSImage *)createSingleWindowShot:(NSDictionary * )window;
- (NSImage *)createMultiWindowShot:(NSArray*)selection;
- (NSImage *)getImage:(CGImageRef)cgImage;
- (BOOL)saveImage:(NSImage *)image atPath:(NSString *)path;

- (IBAction)capture:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)changeInterval:(id)sender;

@end
