//
//  WindowListDataSource.m
//  Screenlapse
//

#import "WindowListDataSource.h"

@implementation WindowListDataSource

-(id)init
{
  if(self = [super init])
  {
    [self reload];
  }
  return self;
}

# pragma mark -
# pragma mark Datasource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [windowList count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSDictionary * item = (NSDictionary *)[windowList objectAtIndex:row];
  
  NSString * owner = [item objectForKey:@"kCGWindowOwnerName"];
  NSString * name = [item objectForKey:@"kCGWindowName"];

  CGRect bounds = [self getBoundsFromWindow:item];

  CGImageRef windowImage = CGWindowListCreateImage(CGRectNull,
                                                     kCGWindowListOptionIncludingWindow,
                                                     (CGWindowID)[[item objectForKey:@"kCGWindowNumber"] unsignedIntValue],
                                                     kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);

  NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
  NSImage *image = [[NSImage alloc] init];
  [image addRepresentation:bitmapRep];

  ScreenlapseTableCellView * result = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
  result.textField.stringValue = [NSString stringWithFormat:@"%@ at %dx%d", owner, (int)bounds.size.width, (int)bounds.size.height];
  result.subtextField.stringValue = name;
  result.imageView.image = image;

  return result;
}

# pragma mark -
# pragma mark Delegate

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
  selectedApplications = [windowList objectsAtIndexes:[notification.object selectedRowIndexes]];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"windowListSelectionUpdate"
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:selectedApplications
                                                                                         forKey:@"selectedApplications"]];
}

# pragma mark -
# pragma mark Custom

-(void)reload
{
  windowList = [NSMutableArray array];

  CFArrayRef windows = CGWindowListCopyWindowInfo(kCGWindowListOptionAll | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
  NSArray * tmpList = (NSArray *)CFBridgingRelease(windows);
  
  for(id win in tmpList)
  {
    CGRect bounds = [self getBoundsFromWindow:win];
    
    if([[win objectForKey:@"kCGWindowLayer"] integerValue] == 0
    && [[win objectForKey:@"kCGWindowName"] isNotEqualTo:@""]
    && bounds.size.width > 100
    && bounds.size.height > 100)
    {
      [windowList addObject:win];
    }
  }
}

-(CGRect)getBoundsFromWindow:(NSDictionary *)window
{
  CGRect bounds;
  CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[window objectForKey:@"kCGWindowBounds"], &bounds);
  return bounds;
}

@end
