//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Julicia on 12/3/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
/*@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;*/
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture; //I added this here 12.6.14 so I can make the toolbar smaller or bigger
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) NSInteger rotationIndex;

@end

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        self.rotationIndex = 1;
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            button.backgroundColor = colorForThisButton;
            button.tintColor = [UIColor whiteColor];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        //[self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        //On lines 70&71, I tell the gesture recognizer which to call the pinchFired method when a pinch is detected
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
        
        
    }
    
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2.5;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2.1;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }

        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}



#pragma mark - Touch Handling

- (UIButton *) buttonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UIButton class]]) {
        return (UIButton *)subview;
    } else {
        return nil;
    }

}


#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

#pragma mark - Tap and Pan Gestures

/*- (void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.buttons containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).text];
                
            }
        }
    }
}*/

- (void) buttonPressed:(UIButton *)sender {
    [self.delegate floatingToolbar:self didSelectButtonWithTitle:[sender titleForState:UIControlStateNormal]];
}


- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
    
    
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
        [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
    
    }
         
    [recognizer setTranslation:CGPointZero inView:self];
         
    }
}

#pragma Pinch Gesture & Long Press Gesture
//11.6.14 I implement the pinch gesture method below -
- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    CGFloat newScaleAmount = [recognizer scale];

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToScaleToSize:)]) {
            [self.delegate floatingToolbar:self didTryToScaleToSize:newScaleAmount];
        }
        NSLog(@"New scale: %.2f",newScaleAmount);
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // restore normal scale
        self.transform = CGAffineTransformIdentity;
        NSLog(@"New scale: 1.00");
    }
}
    
    
- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint longPressLocation = [recognizer locationInView:self];
        UIView *longPressView = [self hitTest:longPressLocation withEvent:nil];
        
        if ([self.buttons containsObject:longPressView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didLongPressButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didLongPressButtonWithTitle:[((UIButton *)longPressView) titleForState:UIControlStateNormal]];
            }
            
        }
    }
    
}

- (void) rotateColors {
    self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                    [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                    [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                    [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
    
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    
    /*
    for (NSInteger i = 0; i < 50; i++) {
        NSLog(@"i = %li / i %% 2 = %li / i mod 11 = %li / i mod 20 = %li",i,i%2,i%11,i%20);
    }
    */
    
    // Make the 4 labels
    for (NSInteger row = 0; row<=3; row++) {
        UIButton *button = (UIButton*)self.subviews[row];
        UIColor *colorForThisButton = [self.colors objectAtIndex:(row + self.rotationIndex)%4];
        NSLog(@"Rotated colors to position %li",(row + self.rotationIndex)%4);
        button.backgroundColor = colorForThisButton;
        }
    self.rotationIndex++;
}

@end
