#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UITextViewExtension : UITextView

@property(nonatomic, copy)   NSString *placeholder;
@property(nonatomic, assign) NSInteger maxTextLength;

// api
- (void)setPlaceholderFont:(UIFont *)font;
- (void)setPlaceholderColor:(UIColor *)color;
- (void)setPlaceholderOpacity:(float)opacity;

@end
