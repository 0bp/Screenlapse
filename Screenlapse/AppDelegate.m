//
//  AppDelegate.m
//  Screenlapse
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  windowListDS = [[WindowListDataSource alloc] init];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateSelection:)
                                               name:@"windowListSelectionUpdate"
                                             object:windowListDS];
  
  [_WindowList setDataSource:windowListDS];
  [_WindowList setDelegate:windowListDS];
  
  [_captureButton setEnabled:NO];
  [self updateIntervalMenu];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
  return YES;
}

# pragma mark -
# pragma mark Events

-(void)updateSelection:(NSNotification *)notification
{
  selectedApplications = [notification.userInfo objectForKey:@"selectedApplications"];
  
  NSInteger count = [selectedApplications count];
  
  if(count == 0)
  {
    [_previewView setImage:nil];
    [_captureButton setEnabled:NO];
    [_reloadButton setEnabled:YES];
  }
  else if(count == 1)
  {
    NSImage * image = [self createSingleWindowShot:[selectedApplications objectAtIndex:0]];
    [_previewView setImage:image];
    [_captureButton setEnabled:YES];
  }
  else
  {
    NSImage * image = [self createMultiWindowShot:selectedApplications];
    [_previewView setImage:image];
    [_captureButton setEnabled:YES];
  }
}

# pragma mark -
# pragma mark Methods

-(NSImage *)createSingleWindowShot:(NSDictionary * )window
{
	CGImageRef windowImage = CGWindowListCreateImage(CGRectNull,
                                                   kCGWindowListOptionIncludingWindow,
                                                   (CGWindowID)[[window objectForKey:@"kCGWindowNumber"] unsignedIntValue],
                                                   kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
  return [self getImage:windowImage];
}

-(NSImage *)createMultiWindowShot:(NSArray*)selection
{
  float totalWidth = 0;
  float maxHeight = 0;
  for(id win in selection)
  {
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull,
                                                     kCGWindowListOptionIncludingWindow,
                                                     (CGWindowID)[[win objectForKey:@"kCGWindowNumber"] unsignedIntValue],
                                                     kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
    
    totalWidth += CGImageGetWidth(windowImage);
    maxHeight = MAX(maxHeight,CGImageGetHeight(windowImage));
  }

  CGContextRef context = CGBitmapContextCreate(NULL, totalWidth, maxHeight, 8, totalWidth*4, CGColorSpaceCreateDeviceRGB(), kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
  float lastX = 0;
  for(id win in selection)
  {
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull,
                                                     kCGWindowListOptionIncludingWindow,
                                                     (CGWindowID)[[win objectForKey:@"kCGWindowNumber"] unsignedIntValue],
                                                     kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);

    CGRect rect = (CGRect){lastX, 0, {CGImageGetWidth(windowImage), CGImageGetHeight(windowImage)}};
    CGContextDrawImage(context, rect, windowImage);
    lastX += CGImageGetWidth(windowImage);
  }
  
  CGImageRef newImageRef = CGBitmapContextCreateImage(context);

  return [self getImage:newImageRef];
}

-(NSImage *)getImage:(CGImageRef)cgImage
{
  NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
  NSImage *image = [[NSImage alloc] init];
  [image addRepresentation:bitmapRep];
  return image;
}

- (NSString *)currentDatetime
{
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"YYYY-mm-dd-hh-mm-ss"];
  
  NSString *dateTime = [NSString stringWithFormat:@"%@",[outputFormatter stringFromDate:[NSDate date]]];
  
  return dateTime;
}

-(void)saveInterval:(NSTimer *)timer
{
  NSString * filename = [NSString stringWithFormat:@"%@/screenlapse-%@.jpg",
                         [timer.userInfo objectForKey:@"path"],
                         [self currentDatetime]];
  
  NSInteger count = [selectedApplications count];
  NSImage * image;
  
  if(count == 0)
  {
    [_previewView setImage:nil];
  }
  else if(count == 1)
  {
    image = [self createSingleWindowShot:[selectedApplications objectAtIndex:0]];
    [_previewView setImage:image];
  }
  else
  {
    image = [self createMultiWindowShot:selectedApplications];
    [_previewView setImage:image];
  }
  
  [self saveImage:image atPath:filename];
  
}

- (BOOL)saveImage:(NSImage *)image atPath:(NSString *)path
{
  NSBitmapImageRep *rep = [[image representations] objectAtIndex: 0];
  
  NSData *data;
  data = [rep representationUsingType: NSJPEGFileType
                           properties: nil];
  
  BOOL result = [data writeToFile:path atomically:YES];
  return result;
}

- (void)updateIntervalMenu
{
  NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  NSString * intervalValue = [defaults objectForKey:@"interval"];
  
  NSString * defaultInterval = @"5";
  
  if(intervalValue != nil && [intervalValue isNotEqualTo:@""])
  {
    defaultInterval = intervalValue;
  }
  
  NSArray * intervals = [NSArray arrayWithObjects:_Interval_1, _Interval_5, _Interval_10, _Interval_15, _Interval_20, _Interval_30, _Interval_60, nil];
  for(NSMenuItem * item in intervals)
  {
    if([item tag] == [defaultInterval integerValue])
    {
      [item setState:NSOnState];
    }
    else
    {
      [item setState:NSOffState];
    }
  }
}

- (float)getSelectedInterval
{
  NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  NSString * intervalValue = [defaults objectForKey:@"interval"];
  
  if(intervalValue != nil && [intervalValue isNotEqualTo:@""])
  {
    return [intervalValue floatValue];
  }
  return 5.0f;
}

# pragma mark -
# pragma mark Button Actions

-(IBAction)capture:(id)sender
{
  if(capturing)
  {
    [_reloadButton setEnabled:YES];
    [_windowTableView setEnabled:YES];
    capturing = NO;

    [interval invalidate];
    interval = nil;
    return;
  }

  [_reloadButton setEnabled:NO];
  [_windowTableView setEnabled:NO];
  [_captureButton setEnabled:NO];
  capturing = YES;

  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  [openDlg setCanChooseFiles:NO];
  [openDlg setCanChooseDirectories:YES];
  [openDlg setAllowsMultipleSelection:NO];
  [openDlg setCanCreateDirectories:YES];

  [openDlg beginWithCompletionHandler:^(NSInteger result){
    if (result == NSFileHandlingPanelOKButton)
    {
      NSURL *fileURL = [openDlg URL];
      
      interval = [NSTimer scheduledTimerWithTimeInterval:[self getSelectedInterval]
                                       target:self
                                     selector:@selector(saveInterval:)
                                     userInfo:[NSDictionary dictionaryWithObject:[fileURL path] forKey:@"path"]
                                      repeats:YES];
      
    }
    else
    {
      [_reloadButton setEnabled:YES];
      [_windowTableView setEnabled:YES];
      [_captureButton setState:NSOffState];
      capturing = NO;
    }
    [_captureButton setEnabled:YES];
  }];
}

- (IBAction)reload:(id)sender
{
  [windowListDS reload];
  [_previewView setImage:nil];
  [_windowTableView reloadData];
}

- (IBAction)changeInterval:(id)sender
{
  NSString * value = [NSString stringWithFormat:@"%ld", [sender tag]];
    
  NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:value forKey:@"interval"];
  
  [self updateIntervalMenu];
}




@end
