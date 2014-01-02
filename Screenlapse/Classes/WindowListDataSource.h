//
//  WindowListDataSource.h
//  Screenlapse
//

#import <Foundation/Foundation.h>
#import "ScreenlapseTableCellView.h"

@interface WindowListDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
  NSMutableArray * windowList;
  NSArray * selectedApplications;
}

-(void)reload;

@end
