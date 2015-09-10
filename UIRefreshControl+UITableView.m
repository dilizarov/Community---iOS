//
//  UIRefreshControl+UITableView.m
//  
//
//  Created by David Ilizarov on 9/9/15.
//
//

#import "UIRefreshControl+UITableView.h"

@implementation UIRefreshControl (UITableView)

- (void)addToTableView:(UITableView *)tableView
{
    if (self.superview != tableView)
    {
        SEL _setRefreshControl = sel_registerName("_setRefreshControl:");
        
        if (self.superview)
        {
            UIView *oldTableView = self.superview;
            if ([oldTableView isKindOfClass:UITableView.class])
            {
                if ([tableView respondsToSelector:_setRefreshControl])
                { // UITableView has a _setRefreshControl method
                    ((void (*)(id, SEL, __strong UIRefreshControl *))[tableView methodForSelector:_setRefreshControl])(oldTableView, _setRefreshControl, nil);
                }
                else
                { // Some future version, UITableView does not have a _setRefreshControl method. So hack it using a UITableViewController
                    UIView *superview = oldTableView.superview;
                    UITableViewController *tvc = [[UITableViewController alloc] init];
                    tvc.tableView = (UITableView *)oldTableView;
                    tvc.refreshControl = nil;
                    tvc.tableView = nil;
                    [superview addSubview:oldTableView];
                }
            }
            
            [self removeFromSuperview];
        }
        if (tableView)
        {
            [tableView addSubview:self];
            
            if ([tableView respondsToSelector:_setRefreshControl])
            { // UITableView has a _setRefreshControl method
                ((void (*)(id, SEL, __strong UIRefreshControl *))[tableView methodForSelector:_setRefreshControl])(tableView, _setRefreshControl, self);
            }
            else
            { // Some future version, UITableView does not have a _setRefreshControl method. So hack it using a UITableViewController
                UIView *superview = tableView.superview;
                UITableViewController *tvc = [[UITableViewController alloc] init];
                tvc.tableView = tableView;
                tvc.refreshControl = self;
                tvc.tableView = nil;
                [superview addSubview:tableView];
            }
        }
    }
}

@end