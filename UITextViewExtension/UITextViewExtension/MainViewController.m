#import "MainViewController.h"

#import "UIColor+HexString.h"
#import "UITextViewExtension.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SCALE_WIDTH_L SCREEN_WIDTH / 667.0
#define SCALE_HEIGHT_L SCREEN_HEIGHT / 375.0

#define SCALE_WIDTH_P SCREEN_WIDTH / 375.0
#define SCALE_HEIGHT_P SCREEN_HEIGHT / 667.0

#define WeakSelf __weak typeof(self) weakSelf = self;

@interface MainViewController() <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UITextViewExtension *textView;

@property (nonatomic, strong) UIButton *navControlButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialData];
    [self detectOrientation];
}

#pragma mark - 初始化数据
- (void)initialData {
    
    [self configUI];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // 增加监听，当屏幕旋转时感知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - UI
- (void)configUI {
    self.title = @"UITextViewExtension";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.image = [UIImage imageNamed:@"BG3"];
    [self.view addSubview:_bgImageView];
    
    _textView = [UITextViewExtension new];
    // 设置placeholder
    _textView.placeholder = @"This is placeholder ~";
    // 设置placeholder颜色 不设置默认为textfield的placeholder的颜色
    [_textView setPlaceholderColor:[UIColor redColor]];
    // 设置textView输入最大长度
    _textView.maxTextLength = 16;
    // 设置textView的透明度
    [_textView setPlaceholderOpacity:0.5f];
    
    _textView.font = [UIFont fontWithName:@"PingFang-SC-Regular" size:14.0f];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.cornerRadius = 4.0f;
    _textView.layer.masksToBounds = YES;
    [self.view addSubview:_textView];
    

}

#pragma mark - 设置屏幕旋转事件
- (void)detectOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        _bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgImageView.image = [UIImage imageNamed:@"BG3"];
        _textView.frame = CGRectMake(30.0f, 32.0f + 15.0f + 20.0f, SCREEN_WIDTH - 60.0f, SCREEN_HEIGHT - 44 - 30 - 13 - 45 * SCALE_HEIGHT_L - 15);
        
    }else {
        _bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgImageView.image = [UIImage imageNamed:@"BG3"];
        _textView.frame = CGRectMake(30.0f, 44.0f + 15.0f + 20.0f, SCREEN_WIDTH - 60.0f, SCREEN_HEIGHT - 44 - 30 - 13 - 45 * SCALE_HEIGHT_P - 15);
    }
}

#pragma mark - 点击其他位置收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textView resignFirstResponder];
}

#pragma mark - status bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
