/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <Lottie/Lottie.h>

#import <React/RCTComponent.h>
#import <React/RCTScrollableProtocol.h>

@interface RCTRefreshControlCustom : UIRefreshControl <RCTCustomRefreshContolProtocol>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) RCTDirectEventBlock onRefresh;
@property (nonatomic, weak) UIScrollView *scrollView;

@end
