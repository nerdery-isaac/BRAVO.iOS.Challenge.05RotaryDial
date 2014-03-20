//
//  NRDMainViewController.m
//  RotaryDial
//
//  Created by Isaac Greenspan on 3/19/14.
//  Copyright (c) 2014 The Nerdery. All rights reserved.
//

#import "NRDMainViewController.h"

@interface NRDMainViewController ()

@property (nonatomic, assign) NSInteger dialValue;
@property (nonatomic, assign) CGPoint initialHandlePoint;

@property (nonatomic, weak) IBOutlet UIView *dialContainerView;
@property (nonatomic, weak) IBOutlet UILabel *dialValueLabel;

- (IBAction)leftHalfTapped:(UITapGestureRecognizer *)sender;
- (IBAction)rightHalfTapped:(UITapGestureRecognizer *)sender;
- (IBAction)handlePanned:(UIPanGestureRecognizer *)sender;

@end


static NSUInteger const kTotalSteps = 60;
static NSUInteger const kTapSnapSize = kTotalSteps / 12;
static CGFloat const kRotationPerStep = 2.0 * M_PI / kTotalSteps;


@implementation NRDMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dialValue = kTotalSteps;
}

#pragma mark - Overridden setters/getters

- (void)setDialValue:(NSInteger)dialValue
{
    if (_dialValue != dialValue) {
        _dialValue = dialValue % kTotalSteps;
        if (_dialValue == 0) {
            _dialValue = kTotalSteps;
        }
        self.dialValueLabel.text = [NSString stringWithFormat:@"%d", self.dialValue];
    }
}

#pragma mark - helpers

- (void)adjustDialBy:(NSInteger)steps
{
    self.dialValue += steps;
    self.dialContainerView.transform = CGAffineTransformMakeRotation(kRotationPerStep * self.dialValue);
}

#pragma mark - IBActions

- (IBAction)leftHalfTapped:(UITapGestureRecognizer *)sender
{
    if (self.dialValue % kTapSnapSize == 0) {
        // We're already snapped to a snap-value, so subtract a whole snap interval.
        [self adjustDialBy:-kTapSnapSize];
    } else {
        // Otherwise, adjust by the remainder.
        [self adjustDialBy:-(self.dialValue % kTapSnapSize)];
    }
}

- (IBAction)rightHalfTapped:(UITapGestureRecognizer *)sender
{
    // Adjust by a whole snap interval, less however far off a snap interval we already are.
    [self adjustDialBy:kTapSnapSize - (self.dialValue % kTapSnapSize)];
}

- (IBAction)handlePanned:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.initialHandlePoint = [sender locationInView:self.dialContainerView];
    }
    // Because the dialContainerView gets rotated, we only ever need to measure the angle based on the initial handle point.
    CGPoint newHandlePoint = [sender locationInView:self.dialContainerView];
    CGPoint center = self.dialContainerView.center;
    CGFloat deltaAngle = (atan2(newHandlePoint.y - center.y, newHandlePoint.x - center.x)
                          - atan2(self.initialHandlePoint.y - center.y, self.initialHandlePoint.x - center.x));
    [self adjustDialBy:round(deltaAngle / kRotationPerStep)];
}

@end
