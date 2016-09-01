#import "UITextViewExtension.h"


#define kTopY 7.0
#define kLeftX 5.0

@interface UITextViewExtension ()

// textView 最大长度限制
- (void)addMaxTextLengthWithMaxLength:(NSInteger)maxLength andEvent:(void(^)(UITextViewExtension *text))limit;
// 开始编辑的回调
- (void)addTextViewBeginEvent:(void(^)(UITextViewExtension *text))begin;
// 结束编辑的回调
- (void)addTextViewEndEvent:(void(^)(UITextViewExtension *text))End;

@property(assign, nonatomic) float updateHeight;

@end

@interface UITextViewExtension() <UITextViewDelegate>

@property(strong, nonatomic) UIColor *placeholder_color;
@property(strong, nonatomic) UIFont * placeholder_font;
@property(strong, nonatomic, readonly)  UILabel *placeholderLabel;
@property(assign, nonatomic) float placeholdeWidth;

@property(copy,nonatomic) id eventBlock;
@property(copy,nonatomic) id beginBlock;
@property(copy,nonatomic) id endBlock;

@end

@implementation UITextViewExtension

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChange:) name:UITextViewTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewBeginNoti:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEndNoti:) name:UITextViewTextDidEndEditingNotification object:self];
}

- (void)dealloc {
    [_placeholderLabel removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [self initialize];
    
    float left = kLeftX,top = kTopY, hegiht = 30.0f;
    self.placeholdeWidth = CGRectGetWidth(self.frame) - 2 * left;
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, _placeholdeWidth, hegiht)];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByWordWrapping;
    [self addSubview:_placeholderLabel];
    [self defaultConfig];
    
}

- (void)layoutSubviews {
    float left = kLeftX, top = kTopY, hegiht = self.bounds.size.height;
    self.placeholdeWidth = CGRectGetWidth(self.frame) - 2 * left;
    CGRect frame = _placeholderLabel.frame;
    frame.origin.x = left;
    frame.origin.y = top;
    frame.size.height = hegiht;
    frame.size.width = self.placeholdeWidth;
    _placeholderLabel.frame = frame;
    [_placeholderLabel sizeToFit];
    
}

- (void)defaultConfig {
    self.placeholderColor = [UIColor lightGrayColor];
    self.placeholderFont  = self.font;
    self.maxTextLength = 1000;
    self.layoutManager.allowsNonContiguousLayout = NO;
}

#pragma mark - textView 编辑
- (void)addMaxTextLengthWithMaxLength:(NSInteger)maxLength andEvent:(void (^)(UITextViewExtension *text))limit {
    if (maxLength > 0) {
        _maxTextLength = maxLength;
        
    }else if (limit) {
        _eventBlock = limit;
    }
}

- (void)addTextViewBeginEvent:(void (^)(UITextViewExtension *))begin {
    _beginBlock = begin;
}

-(void)addTextViewEndEvent:(void (^)(UITextViewExtension *))end {
    _endBlock = end;
}

- (void)setUpdateHeight:(float)updateHeight {
    CGRect frame = self.frame;
    frame.size.height = updateHeight;
    self.frame = frame;
    _updateHeight = updateHeight;
}

#pragma mark - api
- (void)setPlaceholderFont:(UIFont *)font {
    self.placeholder_font = font;
}

- (void)setPlaceholderColor:(UIColor *)color {
    self.placeholder_color = color;
    
}

- (void)setPlaceholderOpacity:(float)opacity {
    if (opacity < 0.0f) {
        opacity = 1.0f;
    }
    self.placeholderLabel.layer.opacity = opacity;
}

#pragma mark - private method

+ (float)boundingRectWithSize:(CGSize)size withLabel:(NSString *)label withFont:(UIFont *)font{
    NSDictionary *attribute = @{NSFontAttributeName:font};
    // CGSize retSize;
    CGSize retSize = [label boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:attribute
                                         context:nil].size;
    
    return retSize.height;
    
}

#pragma mark - getters and Setters
- (void)setText:(NSString *)tex{
    if (tex.length > 0) {
        _placeholderLabel.hidden=YES;
    }
    [super setText:tex];
}

- (void)setPlaceholder:(NSString *)placeholder{
    if (placeholder.length == 0 || [placeholder isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    }
    else {
        _placeholderLabel.text = placeholder;
        _placeholder = placeholder;
    }
}

- (void)setPlaceholder_font:(UIFont *)placeholder_font {
    _placeholder_font = placeholder_font;
    _placeholderLabel.font = placeholder_font;
}

-(void)setPlaceholder_color:(UIColor *)placeholder_color {
    _placeholder_color = placeholder_color;
    _placeholderLabel.textColor = placeholder_color;
}

#pragma mark - Noti Event

- (void)textViewBeginNoti:(NSNotification*)noti{
    
    if (_beginBlock) {
        void(^begin)(UITextViewExtension *text) = _beginBlock;
        begin(self);
    }
}

-(void)textViewEndNoti:(NSNotification*)noti{
    
    if (_endBlock) {
        void(^end)(UITextViewExtension *text) = _endBlock;
        end(self);
    }
}

- (void)didChange:(NSNotification*)noti{
    
    if (self.placeholder.length == 0 || [self.placeholder isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    }else if (self.text.length > 0) {
        _placeholderLabel.hidden = YES;
    }else {
        _placeholderLabel.hidden = NO;
    }
    
    NSString *lang = [[self.nextResponder textInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (self.text.length > self.maxTextLength) {
                self.text = [self.text substringToIndex:self.maxTextLength];
            }
        }
    }else {
        if (self.text.length > self.maxTextLength) {
            self.text = [ self.text substringToIndex:self.maxTextLength];
        }
    }
    
    if (_eventBlock && self.text.length > self.maxTextLength) {
        void (^limit)(UITextViewExtension *text) = _eventBlock;
        limit(self);
    }
    
}


@end
