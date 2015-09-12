//
//  UIRefreshControl+beginRefreshing.m
//  Kibo
//
//  Created by Hlung on 3/6/15.
//  MIT License
//

#import "UIRefreshControl+beginRefreshing.h"

@implementation UIRefreshControl (beginRefreshing)

- (void)beginRefreshingProgrammatically {
    // add delay so tintColor that is set in the same runloop takes effect
    [self performSelector:@selector(do_beginRefreshingProgrammatically) withObject:nil afterDelay:0];
}

- (void)do_beginRefreshingProgrammatically {
    [self beginRefreshing];
    
    // beginRefreshing doesn't make the tableView reveal the refreshControl, so we have to do it manually
    UITableView *tableView = [self getParentTableViewOfView:self];
    if (tableView) {
        [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y-self.frame.size.height) animated:YES];
    }
}

// recursively find a UITableView in superviews
- (UITableView *)getParentTableViewOfView:(UIView*)view {
    if ([view.superview isKindOfClass:[UITableView class]]) {
        return (UITableView *)view.superview;
    }
    return nil;
}

@end