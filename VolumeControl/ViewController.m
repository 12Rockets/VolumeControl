//
//  ViewController.m
//  VolumeControl
//
//  Created by Aleksandra Stevović on 11/16/15.
//  Copyright © 2015 Aleksandra Stevović. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <VolumeControlDelegate>

@property (nonatomic, strong)VolumeControl *control;       // Volume Control
@property (nonatomic, strong)UIView *viewForVolumeControl; // Shading view behind VolumeControl
@property (nonatomic)CGFloat volume;                       // Volume slider value
@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.volume = 50;
    
// Custumize Navigation bar
    
    [self setTitle:@"Volume Control"];
    self.navigationController.navigationBar.barTintColor = [UIColor GRAY_COLOR];
    self.navigationController.navigationBar.translucent = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect screen = self.navigationController.view.bounds;
    
// Create superview for VolumeControl
    
    self.viewForVolumeControl = [[UIView alloc]initWithFrame: self.navigationController.view.frame];
    self.viewForVolumeControl.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    [self.navigationController.view addSubview:self.viewForVolumeControl];
    [self.viewForVolumeControl setHidden:YES];
    
// Create Volume Control
    
    self.control = [[VolumeControl alloc] initWithCenter:CGPointMake(screen.size.width, screen.size.height)
                                              withRadius:screen.size.width*0.50
                                              withVolume:self.volume/100
                               withVolumeControlDelegate:self];
    
    [self.viewForVolumeControl addSubview:self.control];

}



- (IBAction)onVolumeButton:(id)sender {

// Show VolumeControl
    
    [self.control setHidden:NO];
    
// Animate VolumeControl's superview fading
    
    [self.viewForVolumeControl setHidden:NO];
    [UIView animateWithDuration:0.2f animations:^{
        
        self.viewForVolumeControl.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6f];
        
    } completion:^(BOOL finished) { }];
    
}

#pragma mark - VolumeControlDelegate

- (void)didChangeVolume:(CGFloat)volume
{
    // Code for handling changes of volume value
}
- (void)viewIsHidden:(BOOL)ishidden
{
// Animate VolumeControl's superview fading
// NOTE: (BOOL)ishidden will always be YES
    
    [UIView animateWithDuration:0.2f animations:^{
        
        self.viewForVolumeControl.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0f];
        
    } completion:^(BOOL finished) {
        [self.viewForVolumeControl setHidden:YES];
    }];
    
}

#pragma mark - 12Rockets

- (IBAction)on12Rockets:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://12rockets.com"]];
}

@end
