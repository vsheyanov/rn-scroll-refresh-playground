/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTRefreshControlCustom.h"
#import "RCTRefreshableProtocolCustom.h"

#import "React/RCTUtils.h"

@interface RCTRefreshControlCustom () <RCTRefreshableProtocolCustom>
@end

@implementation RCTRefreshControlCustom {
  BOOL _isInitialRender;
  BOOL _currentRefreshingState;
  UInt64 _currentRefreshingStateClock;
  UInt64 _currentRefreshingStateTimestamp;
  BOOL _refreshingProgrammatically;
  NSString *_title;
  UIColor *_titleColor;
  CGFloat _progressViewOffset;
}

- (instancetype)init
{
  if ((self = [super init])) {
    [self addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];

//    UIImageView *paintView = [[UIImageView alloc]initWithFrame:CGRectZero];
//    paintView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://images.ctfassets.net/2mwev93abaf1/6CAyb9D9JcGTMJOw2o7Wxw/db6cab6329783f5011de5955ea60e79d/Home.jpg?w=2500&h=1292&q=80&fm=webp"]]];

//    UIImageView *paintView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//    paintView.image = [UIImage imageNamed:@"guidion_loader.gif"];
//    paintView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"guidion_loader.gif" ofType:@""]];

//    [paintView setBackgroundColor:[UIColor yellowColor]];

//    paintView.translatesAutoresizingMaskIntoConstraints = false;

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //                            IMPORTANT!!!!
    // this is where all magic happens. In the final implementation it is crutual to find
    // the right positioning for the Lottie animation
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    LOTAnimationView *paintView = [LOTAnimationView animationNamed:@"animation"];
    paintView.contentMode = UIViewContentModeScaleAspectFill;

    [self addSubview:paintView];

    paintView.loopAnimation = true;

//    [paintView play];
    [paintView playWithCompletion:^(BOOL animationFinished) {
      // Do Something
    }];

    CGRect lottieRect = CGRectMake(self.bounds.size.width/2 + 15, 0, 50, 50);
    paintView.frame = lottieRect;

    NSLayoutConstraint *width =[NSLayoutConstraint
                                        constraintWithItem:paintView
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:50];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                         constraintWithItem:paintView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0
                                         constant:50];
    NSLayoutConstraint *top = [NSLayoutConstraint
                                       constraintWithItem:paintView
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeTop
                                       multiplier:1.0f
                                       constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                           constraintWithItem:paintView
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                           attribute:NSLayoutAttributeLeading
                                           multiplier:1.0f
                                           constant:0.f];
//    [self addConstraint:width];
//    [self addConstraint:height];
//    [self addConstraint:top];
//    [self addConstraint:leading];

    self.tintColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];

    _currentRefreshingStateClock = 1;
    _currentRefreshingStateTimestamp = 0;
    _isInitialRender = true;
    _currentRefreshingState = false;
  }
  return self;
}

RCT_NOT_IMPLEMENTED(-(instancetype)initWithCoder : (NSCoder *)aDecoder)

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self _applyProgressViewOffset];

  // Fix for bug #7976
  if (self.backgroundColor == nil) {
    self.backgroundColor = [UIColor clearColor];
  }

  // If the control is refreshing when mounted we need to call
  // beginRefreshing in layoutSubview or it doesn't work.
  if (_currentRefreshingState && _isInitialRender) {
    [self beginRefreshingProgrammatically];
  }
  _isInitialRender = false;
}

- (void)beginRefreshingProgrammatically
{
  UInt64 beginRefreshingTimestamp = _currentRefreshingStateTimestamp;
  _refreshingProgrammatically = YES;

  // Fix for bug #24855
  [self sizeToFit];

  if (self.scrollView) {
    // When using begin refreshing we need to adjust the ScrollView content offset manually.
    UIScrollView *scrollView = (UIScrollView *)self.scrollView;

    CGPoint offset = {scrollView.contentOffset.x, scrollView.contentOffset.y - self.frame.size.height};

    // `beginRefreshing` must be called after the animation is done. This is why it is impossible
    // to use `setContentOffset` with `animated:YES`.
    [UIView animateWithDuration:0.25
        delay:0
        options:UIViewAnimationOptionBeginFromCurrentState
        animations:^(void) {
          [scrollView setContentOffset:offset];
        }
        completion:^(__unused BOOL finished) {
          if (beginRefreshingTimestamp == self->_currentRefreshingStateTimestamp) {
            [super beginRefreshing];
            [self setCurrentRefreshingState:super.refreshing];
          }
        }];
  } else if (beginRefreshingTimestamp == self->_currentRefreshingStateTimestamp) {
    [super beginRefreshing];
    [self setCurrentRefreshingState:super.refreshing];
  }
}

- (void)endRefreshingProgrammatically
{
  // The contentOffset of the scrollview MUST be greater than the contentInset before calling
  // endRefreshing otherwise the next pull to refresh will not work properly.
  UIScrollView *scrollView = self.scrollView;
  if (scrollView && _refreshingProgrammatically && scrollView.contentOffset.y < -scrollView.contentInset.top) {
    UInt64 endRefreshingTimestamp = _currentRefreshingStateTimestamp;
    CGPoint offset = {scrollView.contentOffset.x, -scrollView.contentInset.top};
    [UIView animateWithDuration:0.25
        delay:0
        options:UIViewAnimationOptionBeginFromCurrentState
        animations:^(void) {
          [scrollView setContentOffset:offset];
        }
        completion:^(__unused BOOL finished) {
          if (endRefreshingTimestamp == self->_currentRefreshingStateTimestamp) {
            [super endRefreshing];
            [self setCurrentRefreshingState:super.refreshing];
          }
        }];
  } else {
    [super endRefreshing];
  }
}

- (void)_applyProgressViewOffset
{
  // progressViewOffset must be converted from the ScrollView parent's coordinate space to
  // the coordinate space of the RefreshControl. This ensures that the control respects any
  // offset in the view hierarchy, and that progressViewOffset is not inadvertently applied
  // multiple times.
  UIView *scrollView = self.superview;
  UIView *target = scrollView.superview;
  CGPoint rawOffset = CGPointMake(0, _progressViewOffset);
  CGPoint converted = [self convertPoint:rawOffset fromView:target];
  self.frame = CGRectOffset(self.frame, 0, converted.y);
}

- (NSString *)title
{
  return _title;
}

- (void)setTitle:(NSString *)title
{
  _title = title;
  [self _updateTitle];
}

- (void)setTitleColor:(UIColor *)color
{
  _titleColor = color;
  [self _updateTitle];
}

- (void)_updateTitle
{
  if (!_title) {
    return;
  }

  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  if (_titleColor) {
    attributes[NSForegroundColorAttributeName] = _titleColor;
  }

  self.attributedTitle = [[NSAttributedString alloc] initWithString:_title attributes:attributes];
}

- (void)setRefreshing:(BOOL)refreshing
{
  if (_currentRefreshingState != refreshing) {
    [self setCurrentRefreshingState:refreshing];

    if (refreshing) {
      if (!_isInitialRender) {
        [self beginRefreshingProgrammatically];
      }
    } else {
      [self endRefreshingProgrammatically];
    }
  }
}

- (void)setCurrentRefreshingState:(BOOL)refreshing
{
  _currentRefreshingState = refreshing;
  _currentRefreshingStateTimestamp = _currentRefreshingStateClock++;
}

- (void)setProgressViewOffset:(CGFloat)offset
{
  _progressViewOffset = offset;
  [self _applyProgressViewOffset];
}

- (void)refreshControlValueChanged
{
  [self setCurrentRefreshingState:super.refreshing];
  _refreshingProgrammatically = NO;

  if (_onRefresh) {
    _onRefresh(nil);
  }
}

@end
