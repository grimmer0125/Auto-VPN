#import <Cocoa/Cocoa.h>

@interface Enhancer : NSObject {
    SEL idleHandler;
}

-(void)enableIdle;
-(void)enableIdleWithHandler:(SEL)handler;
@end