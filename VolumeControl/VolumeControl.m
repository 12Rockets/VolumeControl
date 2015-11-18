//
//  VolumeControl.m
//  AniTest
//
//  Created by Marko Čančar on 20.10.15..
//  Copyright © 2015. Marko Čančar. All rights reserved.
//

#import "VolumeControl.h"

@interface VolumeControl() <UIGestureRecognizerDelegate>

@property (nonatomic)CGPoint controlCenter;
@property (nonatomic)CGFloat controlRadius;

@property (nonatomic)CGFloat endAngle;
@property (nonatomic)CGFloat startAngle;

@property (nonatomic)CGFloat volume;

@property (nonatomic)CGRect hiddingFrame;
@property (nonatomic)CGRect showedFrame;

@property (nonatomic, strong)UIColor *color;

@property(nonatomic, strong) UIPanGestureRecognizer *translationGestureRecognizer;

@end

@implementation VolumeControl

- (instancetype)initWithCenter:(CGPoint)center withRadius:(CGFloat)radius withVolume:(CGFloat)volume withVolumeControlDelegate:(id <VolumeControlDelegate>)delegate
{

    
    self = [super initWithFrame:CGRectMake(center.x, center.y, 1, 1)];
    if (self) {
        self.controlCenter = CGPointMake(radius, radius);
        self.controlRadius = radius;
        _volume = volume;
        _volumeDelegate = delegate;
        self.hidden = YES;
        [self.volumeDelegate viewIsHidden:YES];
        self.backgroundColor = [UIColor clearColor];
        
        self.startAngle = M_PI - asinf(VOLUME_CONTROL_CENTER_OFFSET_PERCENT_Y/(1-VOLUME_CONTROL_INSET_PERCENT)) +
        (VOLUME_CONTROL_INSET_START_END - (VOLUME_CONTROL_LINE_WIDTH/2.0))/self.controlRadius;
        
        
        self.endAngle = M_PI + M_PI_2 + asinf(VOLUME_CONTROL_CENTER_OFFSET_PERCENT_X/(1-VOLUME_CONTROL_INSET_PERCENT)) -
        (VOLUME_CONTROL_INSET_START_END + (VOLUME_CONTROL_LINE_WIDTH/2.0))/self.controlRadius;
    
        self.translationGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTranslationGesture:)];
        self.translationGestureRecognizer.minimumNumberOfTouches = 1;
        self.translationGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:self.translationGestureRecognizer];
        self.translationGestureRecognizer.delegate = self;
    }
    return self;
}


- (void)setVolume:(CGFloat)volume
{
    [self volumeChanged:volume];
    [self.volumeDelegate didChangeVolume:volume];
}

- (void)volumeChanged:(CGFloat)volume
{
    _volume = volume/100;
    [self setNeedsDisplay];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHidden:YES];
    [self.volumeDelegate viewIsHidden:YES];
}

- (void)handleTranslationGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self setHidden:YES];
        [self.volumeDelegate viewIsHidden:YES];
        return;
    }
    
    CGPoint checkPoint = [gestureRecognizer locationInView:self];
    
    CGFloat x = self.controlCenter.x - checkPoint.x;
    CGFloat y = self.controlCenter.y - checkPoint.y;
  
    CGFloat r = sqrtf(powf(x, 2.0) + powf(y, 2.0));
    
    CGFloat TETA;
    if (y>0)
    {
        if (x>0)
        {
            TETA = M_PI + acosf(x/r);
        }
        else
        {
            TETA = asinf(-x/r) + 3*M_PI_2;
        }
    }
    else
    {
        if (x>0)
        {
            TETA = M_PI - acosf(x/r);
        }
        else
        {
            TETA = acosf(x/r);
        }
    }
    
    if (TETA > self.endAngle)
        TETA = self.endAngle;

    if (TETA < self.startAngle)
        TETA = self.startAngle;
    
    CGFloat newVolume = (TETA-self.startAngle)/(self.endAngle-self.startAngle) * 100;
    newVolume = roundf(newVolume);
    if (fabs(newVolume/100 - self.volume) > 0.01)
    {
        self.volume = newVolume;
    }
}


// Fix this animations...
- (void)setHidden:(BOOL)hidden
{

    if (CGRectIsEmpty(self.showedFrame))
         {
             CGFloat width = self.controlRadius*(1.0+VOLUME_CONTROL_CENTER_OFFSET_PERCENT_X);
             CGFloat height = self.controlRadius*(1.0+VOLUME_CONTROL_CENTER_OFFSET_PERCENT_Y);
             self.hiddingFrame = self.frame;
             self.showedFrame = CGRectMake(self.frame.origin.x-width, self.frame.origin.y-height, width, height);
         }
         
    if (hidden)
    {
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             self.frame = self.hiddingFrame;
         }
                         completion:^(BOOL finished) {
                             [super setHidden:hidden];
                         }];
    }
    else
    {
        [super setHidden:hidden];

        [self show];
    }
}

- (void)show
{
    [self setNeedsDisplay];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.frame = self.showedFrame;
     }
                     completion:nil];

}

- (void)drawRect:(CGRect)rect
{
    //background
    UIBezierPath *portionPath1 = [UIBezierPath bezierPath];
    [portionPath1 moveToPoint:self.controlCenter];
    [portionPath1 addArcWithCenter:self.controlCenter
                            radius:self.controlRadius
                        startAngle:0.0
                          endAngle:2*M_PI
                         clockwise:YES];
    
    [portionPath1 closePath];
    
    [[UIColor GRAY_COLOR] setFill];

    [portionPath1 fill];
    
    //volume
    [self drawVolume];
    
    //images
    CGFloat width = self.controlRadius*(1.0-VOLUME_CONTROL_CENTER_OFFSET_PERCENT_X);
    CGFloat height = self.controlRadius*(1.0-VOLUME_CONTROL_CENTER_OFFSET_PERCENT_Y);
    
     UIImage *volumeImg = [UIImage imageNamed:@"big-volume-blue.png"];
    CGRect volumeRect = CGRectMake(self.controlCenter.x-volumeImg.size.width/2,
                                   self.controlCenter.y-volumeImg.size.height/2-15.0, volumeImg.size.width, volumeImg.size.height);
    [volumeImg drawInRect:volumeRect];
    
    
    //TODO: Fix this magic.
    UIImage *no_snd = [UIImage imageNamed:@"mute"];
    CGRect no_sndRect = CGRectMake(self.controlCenter.x+no_snd.size.width/2-width+30.0,
                                   self.controlCenter.y-no_snd.size.height/2+40.0, no_snd.size.width, no_snd.size.height);
    [no_snd drawInRect:no_sndRect];

    UIImage *max_snd = [UIImage imageNamed:@"volume.png"];
    CGRect max_sndRect = CGRectMake(self.controlCenter.x-max_snd.size.width/2,
                                   self.controlCenter.y+max_snd.size.height/2-height-10.0, max_snd.size.width, max_snd.size.height);
    [max_snd drawInRect:max_sndRect];
    
}

- (void)drawVolume
{
    CGFloat volumeAngle = fabs(self.endAngle-self.startAngle)*self.volume+self.startAngle;
    
    UIBezierPath *activeVolume = [UIBezierPath bezierPath];
    [activeVolume setLineWidth:VOLUME_CONTROL_LINE_WIDTH];
    
    [activeVolume addArcWithCenter:self.controlCenter
                            radius:self.controlRadius*(1-VOLUME_CONTROL_INSET_PERCENT)
                        startAngle:self.startAngle
                          endAngle:volumeAngle
                         clockwise:YES];
    
    [[UIColor BLUE_COLOR] setStroke];
    [activeVolume stroke];
    
    
    UIBezierPath *inactiveVolume = [UIBezierPath bezierPath];
    [inactiveVolume setLineWidth:VOLUME_CONTROL_LINE_WIDTH/2];
    
    [inactiveVolume addArcWithCenter:self.controlCenter
                              radius:self.controlRadius*(1-VOLUME_CONTROL_INSET_PERCENT)
                          startAngle:volumeAngle
                            endAngle:self.endAngle
                           clockwise:YES];
    
    [[UIColor colorWithWhite:0.3 alpha:1.0] setStroke];
    [inactiveVolume stroke];
    
    CGFloat dotX = self.controlCenter.x-(cosf(volumeAngle-M_PI)*self.controlRadius*(1-VOLUME_CONTROL_INSET_PERCENT)+7.5);
    CGFloat dotY = self.controlCenter.y-(sinf(volumeAngle-M_PI)*self.controlRadius*(1-VOLUME_CONTROL_INSET_PERCENT)+7.5);
    
    CGRect dotRect = CGRectMake(dotX, dotY, 15.0, 15.0);
    
    UIBezierPath *dot = [UIBezierPath bezierPathWithOvalInRect:dotRect];
    
    [[UIColor BLUE_COLOR] setFill];
    
    [dot fill];
}

@end
