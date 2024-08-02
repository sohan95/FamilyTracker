
#import "UINavigationController+AutorotationFromVisibleView.h"

@implementation UINavigationController (AutorotationFromVisibleView)

- (BOOL)shouldAutorotate
{
    if (self.visibleViewController)
    {
        return [self.visibleViewController shouldAutorotate];
    }
    else
    {
        return YES;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.visibleViewController)
    {
        return [self.visibleViewController supportedInterfaceOrientations];
    }
    else
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

@end
