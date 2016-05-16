//
//  AdViewController.m
//  广告轮播
//
//  Created by tarena32 on 16/4/20.
//  Copyright © 2016年 tarena. All rights reserved.
//
/*广告轮播
    怎么实现(基本理念)
    给出三张图片显示中间的一张
    图片左右滚动后重新设置三张图片的内容
    设置当前显示图片为(中间图片视图)位置
    左,右(图片视图)做相应更新设置
 
    需要的数据
 1.基本的对象
 滚动视图UIScrollView
 滚动视图里面的 UIImageView
 滚动视图的页面小圆点显示 UIPageControl
 2.默认设置(进入页面后首先要看到的效果)
    2.1滚动视图的设置
    *属性UIScrollView
        添加到 self.view
        frame(边框的位置,大小)==(可视区域大小)(可以设置为一个图片的边框大小)
        contentSize(内容图片视图的大小)
        contentOffset(显示内容图片视图的起始位置)
        pagingEnabled(是否分页的设置)
        showsHorizontalScrollIndicator(是否显示水平滚动条的设置)(左右滚动,不用考虑上下)
        bounces(是否边缘弹跳设置)
        delegate(设置控制器为代理,处理视图的滚动信息)
    2.2滚动视图里面的 图片视图的 设置
    *属性ImageView(数量可以通过宏定义)(为了节省内存,不可能一下子加载全部视图,需要几个要先考虑清楚)
            添加到 scrollView
            frame(大小一般设置为边框的大小)(添加宏定义宽  高会更好)
            contentMode(设置为按比例大小自适应)[UIView Content Mode Scale Aspect Fit]
            image(图片名字可以通过懒加载的数组获取)
        滚动视图里面的 默认图片的加载
            默认的三张图片为,最后一张,第一张,第二张
    2.3小圆点 的视图设置
    *属性 pageControl
        添加到 self.view
        frame(边框的位置,大小的设置)
        numberOfPages(小圆点的个数和图片的总数量相等)
        page Indicator Tint Color(小圆点的默认 渲染颜色)
        current Page Indicator Tint Color(当前页面小圆点的 渲染颜色)
        currentPage(小圆点当前显示第几页)
 3.数据的更新显示(修改数据)
    需要修改的数据有哪些?
    3.1显示的当前图片的索引(也就是第几张图片)
    3.2UIImageView 中图片的更新
4.需要添加到属性
    *属性
    修改的数据都需要在整个类中可以访问到,所以可以添加到属性中(currentPageIndex图片索引UIImageView 的个数)
    图片的总数 可以从数组中获取,代码太长不是很方便,可以添加到属性
 
 由于整个属性都不希望外面的文件修改访问,所以可以设置为 成员变量
 (名字列表数组要提前写好,可以通过懒加载属性获取,也可以用类方法来获取)
*/


//宏定义不要随便加分号,纯文本替换
#define AD_WIDTH 320
#define AD_HEIGHT 160
#define IMAGEVIEW_COUNT 3


#import "AdViewController.h"

@interface AdViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_leftImageView;
    UIImageView *_centerImageView;
    UIImageView *_rightImageView;
    UIPageControl *_pageControl;
    NSInteger _currentImageIndex;
    NSInteger _imageCount;
}
@property (nonatomic, strong) NSArray *allAdImages;

@end

@implementation AdViewController
-(NSArray *)allAdImages
{
    if (!_allAdImages) {
        _allAdImages = @[@"cm2_daily_banner1",@"cm2_daily_banner2",@"cm2_daily_banner3",@"cm2_daily_banner4",@"cm2_daily_banner5",@"cm2_daily_banner6",@"cm2_daily_banner7"];
    }
    return _allAdImages;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _imageCount = self.allAdImages.count;
    //加载 scrollView
    [self addScrollView];
    //加载 imageView
    [self addImageView];
    //加载 pageControl
    [self addPageControl];
//    //加载第一张屏 默认的三张图片
    [self setDefaultImage];
}

-(void)addScrollView
{
    //添加到当前视图   框架为全屏
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    //配置滚动视图
    //设置 代理
    _scrollView.delegate = self;
    //设置 contentSize
    _scrollView.contentSize = CGSizeMake(AD_WIDTH * IMAGEVIEW_COUNT, AD_HEIGHT);
    //设置当前显示的位置在中间图片
    _scrollView.contentOffset = CGPointMake(AD_WIDTH, 0);
    //设置分页
    _scrollView.pagingEnabled = YES;
    //去掉水平 滚动
    _scrollView.showsHorizontalScrollIndicator = NO;
    //边缘不弹跳
    _scrollView.bounces = YES;
    
}

-(void)addImageView
{//给 ScrollView 添加图片视图
    //
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AD_WIDTH, AD_HEIGHT)];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _leftImageView.image = [UIImage imageNamed:self.allAdImages[_imageCount -1]];
    [_scrollView addSubview:_leftImageView];
    
    _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(AD_WIDTH, 0, AD_WIDTH, AD_HEIGHT)];
    _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _centerImageView.image = [UIImage imageNamed:self.allAdImages[0]];
    [_scrollView addSubview:_centerImageView];
    
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(AD_WIDTH * 2, 0, AD_WIDTH, AD_HEIGHT)];
    _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _rightImageView.image = [UIImage imageNamed:self.allAdImages[1]];
    [_scrollView addSubview:_rightImageView];
}

-(void)addPageControl
{
    _pageControl = [[UIPageControl alloc] init];
    //此方法可以根据校园点页数放回最适合 UIPageControl的大小
//    CGSize size = [_pageControl sizeForNumberOfPages:_imageCount];
    //为了定位可使用 bounds + center
    //定视图的位置是,为了居中,可以通过设置视图的中心点
    _pageControl.bounds = CGRectMake(0, 0,  self.view.frame.size.width, 20);
//    _pageControl.bounds = CGRectMake(0, 0,  size.width, size.height);
    _pageControl.center = CGPointMake(AD_WIDTH * 0.5, AD_HEIGHT - 20);
//    NSLog(@"宽%f,高%f",self.view.frame.size.width,self.view.frame.size.height);
    _pageControl.backgroundColor = [UIColor blackColor];
    
    //设置颜色
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    //设置总页数
    _pageControl.numberOfPages = _imageCount;
    [self.view addSubview:_pageControl];
      //记录当前页
//    _currentImageIndex = 0;
//    _pageControl.currentPage = _currentImageIndex;
    
}

//关于需要修改位置的数据 是否应该写在一个方法内先设置默认值?
//方便后面需要修改数据时 给个参考
-(void)setDefaultImage
{
    _leftImageView.image = [UIImage imageNamed:self.allAdImages[_imageCount-1]];
    _centerImageView.image = [UIImage imageNamed:self.allAdImages[0]];
    _rightImageView.image = [UIImage imageNamed:self.allAdImages[1]];
    // 记录当前页
    _currentImageIndex = 0;
    _pageControl.currentPage = _currentImageIndex;
}

#pragma mark - UIScrollViewDelegate

//停止滚动事件
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //重新加载图片
    [self reloadImage];
    //移动回中间
    _scrollView.contentOffset = CGPointMake(AD_WIDTH, 0);
    //修改分页空间上的小圆点
    _pageControl.currentPage = _currentImageIndex;
}

//重新加载图片
-(void)reloadImage
{
    NSInteger leftimageIndex,rightImageIndex;
    CGPoint offset = _scrollView.contentOffset;
    if (offset.x > AD_WIDTH) {//向右滑动
        _currentImageIndex = (_currentImageIndex + 1)%_imageCount;
    }else if(offset.x < AD_WIDTH){//向左滑动
        _currentImageIndex = (_currentImageIndex - 1 + _imageCount )%_imageCount;
    }
    leftimageIndex =(_currentImageIndex - 1 + _imageCount )%_imageCount;
    rightImageIndex = (_currentImageIndex + 1)%_imageCount;
    
    _leftImageView.image = [UIImage imageNamed:self.allAdImages[leftimageIndex]];
    _centerImageView.image = [UIImage imageNamed:self.allAdImages[_currentImageIndex]];
    _rightImageView.image = [UIImage imageNamed:self.allAdImages[rightImageIndex]];
}
@end
