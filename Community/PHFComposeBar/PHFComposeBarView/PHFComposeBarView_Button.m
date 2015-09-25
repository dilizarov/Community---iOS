#import "PHFComposeBarView_Button.h"
#import "PHFComposeBarView.h"

@implementation PHFComposeBarView_Button

- (void)setHighlighted:(BOOL)highlighted {
    BOOL animating = [((PHFComposeBarView *)self.superview).loadIndicator isAnimating];
    
    if (highlighted) {
        [self setAlpha:0.2f];
    } else {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self setAlpha: (animating ? 0.0f : 1.0f)];
                         }
                         completion: NULL];
    }
}

@end
