//
//  IntervalMenuTransformer.m
//  Screenlapse
//

#import "IntervalMenuTransformer.h"

@implementation IntervalMenuTransformer

+ (Class)transformedValueClass
{
  return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation
{
  return NO;
}
- (id)transformedValue:(id)value
{
  NSInteger count = [value integerValue];
  BOOL boolValue = 0;
  
  if ((count > 1) || (count == 0)) {
    boolValue = 0;
  }else {
    boolValue = 1;
  }
  
  NSNumber *boolNumber = [NSNumber numberWithBool:boolValue];
  
  return boolNumber;
}

@end
