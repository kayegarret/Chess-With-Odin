//
//  ViewController.h
//  Objective-C Playground
//
//  Created by Garret Kaye on 1/9/17.
//  Copyright © 2017 Garret Kaye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheBoard.h"


@interface ViewController : UIViewController

// Share methods with TheBoard
- (void)handleSpotTapped:(UITapGestureRecognizer *)recognizer;
- (void)handlePieceTapped:(UITapGestureRecognizer *)recognizer;

// Share methods with Odin
- (int) performCheckmateAnalysis;
-(void) findAvailableSpots: (NSInteger)withTag pieceObjectPos:(NSString*)pieceObjectPos;
-(void) confirmMove;
- (void) posDataFromOdin: (NSString*)oLastPieceKey oSelectedPiece:(UIImageView*)oSelectedPiece oCurrentObjectKey:(NSString*)oCurrentObjectKey;
-(int) selfInducedCheckAnalysis;
-(int) oppenentInducedCheckAnalysis;
-(void) displayAlert: (NSString*)title message:(NSString*)message;

@property (weak, nonatomic) IBOutlet UIButton *realConfirmButton;
@property (weak, nonatomic) IBOutlet UIButton *realCancelButton;
@property (weak, nonatomic) IBOutlet UIView *realStartMenu;
@property (weak, nonatomic) IBOutlet UIButton *realPlayOdinButton;
@property (weak, nonatomic) IBOutlet UIButton *realPlayLocalButton;
@property (weak, nonatomic) IBOutlet UILabel *realChessTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *realOdinLabel;
@property (weak, nonatomic) IBOutlet UILabel *realYouLabel;


@end

