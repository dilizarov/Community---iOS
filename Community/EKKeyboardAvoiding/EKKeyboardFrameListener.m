//
//  EKKeyboardFrameListener.m
//  EKKeyboardAvoiding
//
//  Created by Evgeniy Kirpichenko on 10/8/13.
//  Copyright (c) 2013 Evgeniy Kirpichenko. All rights reserved.
//

#import "EKKeyboardFrameListener.h"
#import "NSObject+EKKeyboardAvoiding.h"

@interface EKKeyboardFrameListener ()
@property (nonatomic,assign) CGRect keyboardFrame;
@property (nonatomic,assign) CGRect composeBarFrame;
@property (nonatomic,strong) NSDictionary *keyboardInfo;
@end

@implementation EKKeyboardFrameListener

#pragma mark life cycle

- (id)init
{
    if (self = [super init])
    {
        [self startNotificationsObseving];
    }
    return self;
}

- (void)dealloc
{
    [self stopNotificationsObserving];
}

#pragma mark - public methods

- (CGRect)convertedKeyboardFrameForView:(UIView *)view
{
    CGRect convertedFrame = [[view superview] convertRect:[self keyboardFrame] fromView:nil];
    return convertedFrame;
}

#pragma mark - private methods

- (void)startNotificationsObseving
{
    [self observeNotificationNamed:@"PHFComposeBarViewDidChangeFrame" action:@selector(keyboardDidChangeFrame:)];
    
    [self observeNotificationNamed:UIKeyboardDidChangeFrameNotification
                            action:@selector(keyboardDidChangeFrame:)];
}

#pragma mark - observe keyboard frame

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{

    self.keyboardInfo = [notification userInfo];
    
    if ([notification.name  isEqual: @"PHFComposeBarViewDidChangeFrame"])
    {

        NSValue *frameValue = [self.keyboardInfo objectForKey:@"PHFComposeBarViewFrameEnd"];

        CGFloat deltaY = self.composeBarFrame.origin.y - [frameValue CGRectValue].origin.y;
        self.composeBarFrame = [frameValue CGRectValue];
        
        self.keyboardFrame = CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y  - deltaY, self.keyboardFrame.size.width, self.keyboardFrame.size.height + deltaY);
    }
    else
    {
        NSValue *frameValue = [self.keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        if (!CGRectEqualToRect(self.keyboardFrame, [frameValue CGRectValue]))
        {
            self.keyboardFrame = CGRectMake([frameValue CGRectValue].origin.x, [frameValue CGRectValue].origin.y + self.composeBarFrame.origin.y, [frameValue CGRectValue].size.width, [frameValue CGRectValue].size.height - self.composeBarFrame.origin.y);
        }
    }
}

@end
