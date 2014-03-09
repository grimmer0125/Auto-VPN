#import "Enhancer.h"

@interface Enhancer ()

-(void)privateIdleWrapper;

@end

@implementation Enhancer

-(void)privateIdleWrapper {
    
    // AppleScript default idle delay
    NSTimeInterval idleDelay = 30.0;
    
    @try {
        NSNumber* retval = (NSNumber*)[self performSelector:idleHandler];
        
        // If the return value is parseable as a time interval and it's
        // positive, use it as the idle delay.
        NSTimeInterval retDelay = (NSTimeInterval)[retval doubleValue];
        if (retDelay > 0.0) {
            idleDelay = retDelay;
        }
    }
    @catch (...) {
        // do nothing
    }
    [self performSelector:@selector(privateIdleWrapper)
               withObject:nil
               afterDelay:idleDelay];
}

-(void)enableIdle {
    idleHandler = @selector(idle);
    [self performSelector:@selector(privateIdleWrapper)
               withObject:nil
               afterDelay:0.01];
}

-(void)enableIdleWithHandler:(SEL)handler {
    idleHandler = handler;
    [self performSelector:@selector(privateIdleWrapper)
               withObject:nil
               afterDelay:0.01];
}

@end