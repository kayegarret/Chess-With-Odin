//
//  ViewController.m
//  Objective-C Playground
//
//  Created by Garret Kaye on 1/9/17.
//  Copyright © 2017 Garret Kaye. All rights reserved.
//

#import "ViewController.h"
#import "Odin.h"

@interface ViewController ()


@end

ChessBoard* theBoard;
Odin* odin;

@implementation ViewController

int pieceCurrentlySelected;

UIImageView* selectedPiece;
UIView* selectedPieceSpot;
UIView* desiredSpot;
NSString* lastPieceKey;
CGRect lastPieceFrame;
NSMutableArray* tempAvailPositions;
UIView* currentGridSpot;
NSString* currentObjectKey;
UIImageView* pawnForReplacement;

// Odin vars
int odinIsOnline = false;
int isOdinsTurn = false;

// Story Board elements
UIButton* confirmButton;
UIButton* cancelButton;
UIButton* playOdinButton;
UIButton* playLocalButton;
UIView* startMenu;
UILabel* chessTitleLabel;
UILabel* odinLabel;
UILabel* youLabel;


int canSelectPiece;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    pieceCurrentlySelected = false;
    canSelectPiece = true;
    
    // Assign story board elements to holders
    cancelButton = self.realCancelButton;
    confirmButton = self.realConfirmButton;
    startMenu = self.realStartMenu;
    playLocalButton = self.realPlayLocalButton;
    playOdinButton = self.realPlayOdinButton;
    chessTitleLabel = self.realChessTitleLabel;
    odinLabel = self.realOdinLabel;
    youLabel = self.realYouLabel;
    
    // Set confirm and cancel buttons invisable by default since the user had not made a move at this point
    [cancelButton setAlpha:0];
    [confirmButton setAlpha:0];
    
    
    // Listen for a change in device orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // initialize the temp available positions array
    tempAvailPositions = [[NSMutableArray alloc] init];
    currentObjectKey = [[NSString alloc] init];
    currentGridSpot = [[UIView alloc] init];

    
        
    // Initialize the chess board
    theBoard = [[ChessBoard alloc] initWithFrame:self.view.bounds];
    [self.view addSubview: theBoard];
    [self.view sendSubviewToBack:theBoard];
    
    // Initialize odin
    odin = [[Odin alloc] init];
    
    
}

- (void) orientationChanged:(NSNotification *)note
{
    
    CGRect boardFrm = [[UIScreen mainScreen] bounds];
    
    UIDevice * device = note.object;
    UIDeviceOrientation orientation = [device orientation];
    
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        
        // Check to make sure the UIScreen bounds matchs the orientation since some devices are late to update
        if (boardFrm.size.height > boardFrm.size.width) {
            CGFloat tempHeight = boardFrm.size.height;
            CGFloat tempWidth = boardFrm.size.width;
            
            boardFrm.size.height = tempWidth;
            boardFrm.size.width = tempHeight;
        }
        
        boardFrm.size.height -= (boardFrm.size.height/10);
        boardFrm.origin.x = (boardFrm.size.width - boardFrm.size.height) / 2;
        
        boardFrm.size.width = boardFrm.size.height;
        boardFrm.origin.y = (boardFrm.size.height/10)/2;
        
    }
    else {
        
        // Check to make sure the UIScreen bounds matchs the orientation since some devices are late to update
        if (boardFrm.size.width > boardFrm.size.height) {
            CGFloat tempHeight = boardFrm.size.height;
            CGFloat tempWidth = boardFrm.size.width;
            
            boardFrm.size.height = tempWidth;
            boardFrm.size.width = tempHeight;
        }

        boardFrm.size.width -= (boardFrm.size.width/10);
        boardFrm.origin.y = (boardFrm.size.height - boardFrm.size.width) / 2;
        
        boardFrm.size.height = boardFrm.size.width;
        boardFrm.origin.x = (boardFrm.size.width/10)/2;
    }
    
    
    [theBoard setFrame:boardFrm];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

// MARK: Passed data from odin
- (void) posDataFromOdin: (NSString*)oLastPieceKey oSelectedPiece:(UIImageView*)oSelectedPiece oCurrentObjectKey:(NSString*)oCurrentObjectKey {
    
    lastPieceKey = oLastPieceKey;
    selectedPiece = oSelectedPiece;
    currentObjectKey = oCurrentObjectKey;
    
}

// MARK: IB actions
- (IBAction)homeButtonAction:(id)sender {
    
    // Check if user has made any progress
    BOOL userHasMadeProgress = false;
    for (NSString* key in [[theBoard pieces] keyEnumerator]) {
        
        // Get piece
        UIImageView* piece = [theBoard pieces][key];
        
        // Check if piece position is equal to the tag
        if ([[NSString stringWithFormat:@"%d", (int)piece.tag] isEqual:key]) {
            
        }
        else {
            // Piece is not in its starting position, user has made progress
            userHasMadeProgress = true;
        }
        
    }
    
    if (userHasMadeProgress) {
        
        // The user made progress, display alert
        
        [self displayAlert:@"Go Home?" message:@"You will lose all your current progress"];
        
    }
    else {
        
        // No progress has been made therefor no need to display alert
        
        odinIsOnline = false;
        isOdinsTurn = false;
        
        [UIView animateWithDuration:0.75 animations:^{
            [startMenu setAlpha:1];
            [chessTitleLabel setAlpha:1];
            [playOdinButton setAlpha:1];
            [playLocalButton setAlpha:1];
        }completion:^(BOOL finished) {
            [self gameOverReset];
            [self endTurn];
        }];
    }
    
    
}

- (IBAction)confrimButtonAction:(id)sender {
    [self confirmMove];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self cancelMove];
}

- (IBAction)playOdinButtonAction:(id)sender {
    
    // Set player labels accordingly
    [odinLabel setText:@"Odin"];
    [youLabel setText:@"You"];

    odinIsOnline = true;
    [self playOdin];
}

- (IBAction)playLocalButtonAction:(id)sender {
    
    // Set player labels accordingly
    [odinLabel setText:@"Player 2"];
    [youLabel setText:@"Player 1"];
    
    odinIsOnline = false;
    isOdinsTurn = false;
    [UIView animateWithDuration:0.75 animations:^{
        [startMenu setAlpha:0];
    }];
    
}



// MARK: Spot Tapped
- (void)handleSpotTapped:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];

    if (pieceCurrentlySelected == true && selectedPiece != nil) {
        
        selectedPieceSpot.layer.borderWidth = 0;
        selectedPieceSpot = nil;
        
        desiredSpot = recognizer.view;
        
        NSArray *temp = [[theBoard grid] allKeysForObject:recognizer.view];
        NSString *key = [temp lastObject];
        
        if ([self checkSpotSelected:key] == 1) { [tempAvailPositions removeAllObjects]; return; }
        
        // Check if spot is a place the piece has the ability to move too
        int spotIsValid = false;
        for (NSString* gridID in tempAvailPositions) {
            if (gridID == key) {
                spotIsValid = true;
            }
            else {
                ((UIView*)[theBoard grid][gridID]).layer.borderWidth = 0;
            }
        }
        // Clear temp array for next piece to be selected
        [tempAvailPositions removeAllObjects];
        
        // If spot is not valid return
        if (spotIsValid == false) { return; }
        
        if ([theBoard pieces][key] == nil) {
            
        }
        else {
            [((UIImageView*)[theBoard pieces][key]) removeFromSuperview];
        }
        
        
        canSelectPiece = false;
        
        recognizer.view.layer.borderColor = [UIColor greenColor].CGColor;
        recognizer.view.layer.borderWidth = 2;
        
        lastPieceFrame = selectedPiece.frame;
        
        // Rect to go to
        CGRect rectToGoTo = CGRectMake(0, 0, selectedPiece.frame.size.width, selectedPiece.frame.size.height);
        rectToGoTo.origin.x = (recognizer.view.frame.origin.x) + ((recognizer.view.superview.frame.size.width/8) - (recognizer.view.superview.frame.size.width/10)) / 2;
        rectToGoTo.origin.y = (recognizer.view.frame.origin.y) + ((recognizer.view.superview.frame.size.height/8) - (recognizer.view.superview.frame.size.height/10)) / 2;
        
        [UIView animateWithDuration:0.75 animations:^{
            selectedPiece.frame = rectToGoTo;
        }completion:^(BOOL finished){
            
            currentObjectKey = key;
            currentGridSpot = recognizer.view;
            
            [confirmButton setAlpha:1];
            [cancelButton setAlpha:1];
        }];
    }
    
    //Do stuff here...
}

// MARK: Piece Tapped
- (void)handlePieceTapped:(UITapGestureRecognizer *)recognizer {
    
    // Return if it is odins turn
    if (odinIsOnline && isOdinsTurn) { return; }
    
    // Check if dead piece picker is up
    if ([[theBoard deadPiecesPickerView] alpha] == 1) {
        [self deadPieceSelected:(UIImageView*)recognizer.view];
        return;
    }
    
    if (canSelectPiece == false) { return; }
    
    
    if (lastPieceKey != nil) {
        ((UIView*)[[theBoard grid] objectForKey:lastPieceKey]).layer.borderWidth = 0;
    }
    
    // Check if the avail positions array still contains values, if so remove them
    if (tempAvailPositions != nil) {
        
        for (NSString* gridID in tempAvailPositions) {
            ((UIView*)[theBoard grid][gridID]).layer.borderWidth = 0;
        }
        
        [tempAvailPositions removeAllObjects];
        
    }
    
    pieceCurrentlySelected = true;
    selectedPiece = (UIImageView*)recognizer.view;
    
   
    NSArray *temp = [[theBoard pieces] allKeysForObject:selectedPiece];
    NSString *key = [temp lastObject];
    
    
    
    lastPieceKey = key;
    
    selectedPieceSpot = (UIView*)[[theBoard grid] objectForKey:key];
    selectedPieceSpot.layer.borderColor = [UIColor yellowColor].CGColor;
    selectedPieceSpot.layer.borderWidth = 2;
    
    [self findAvailableSpots:selectedPiece.tag pieceObjectPos:key];

}
             
             
             
// MARK: Check Spot Selected
-(int)checkSpotSelected: (NSString*)gridLocation {
    
    int status = 0;
    
    if (((UIImageView*)[theBoard pieces][gridLocation]) != nil) {
        // Spot is occupied
        
        if (((UIImageView*)[theBoard pieces][gridLocation]).isUserInteractionEnabled) {
            // Ally
            if (analyzeForSelfCheck || performingCheckmateAnalysis) {
                // Enemy actually
                status = 2;
            }
            else {
                // Ally actually
                status = 1;
            }
        }
        else {
            // Enemy
            
            if (analyzeForSelfCheck || performingCheckmateAnalysis) {
                // Ally actually
                status = 1;
            }
            else {
                // Enemy actually
                status = 2;
            }

        }
    
    }
    else {
        // Spot is not occupied
        status = 0;
    }
    
    // if 0 spot is empty
    // if 1 spot is occupied by ally
    // if 2 spot is occupied by enemy
    return status;
    
}


// MARK: End Turn

-(void) endTurn {
    
    [tempAvailPositions removeAllObjects];
    
    // Switch userInteraction to enabled for the disabled pieces and vice versa
    for (UIImageView* daPiece in [[theBoard pieces] objectEnumerator]) {
        
        if (daPiece.userInteractionEnabled == true) {
            daPiece.userInteractionEnabled = false;
        }
        else {
            daPiece.userInteractionEnabled = true;
        }
    }
    
    // Do the same for the dead pieces
    for (UIImageView* daPiece in [[theBoard deadPieces] objectEnumerator]) {
        
        if (daPiece.userInteractionEnabled == true) {
            daPiece.userInteractionEnabled = false;
        }
        else {
            daPiece.userInteractionEnabled = true;
        }
    }
    
    // Check to see if odin is online, if so determine whose turn it is
    if (odinIsOnline) {
        if (isOdinsTurn) {
            isOdinsTurn = false;
        }
        else {
            isOdinsTurn = true;
            [odin doSomething:[theBoard pieces] grid:[theBoard grid]];
        }
    }
    
    // Check if local mode is on, if so flip board when turn is done here
    /*
    if (localMode) {
        
        // Check current rotation
        if (CGAffineTransformIsIdentity(theBoard.transform)) {
            // the board is NOT flipped
            
            // Flip board
            [UIView animateWithDuration:0.5 animations:^{
                theBoard.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            
            // Flip pieces
            for (UIImageView* piece in [[theBoard pieces] objectEnumerator]) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    piece.transform = CGAffineTransformMakeRotation(M_PI);
                }];
                
            }
        }
        else {
            // the board IS flipped
            
            // Reverse flip
            [UIView animateWithDuration:0.5 animations:^{
                theBoard.transform = CGAffineTransformMakeRotation(0);
            }];
            
            // Reverse flip pieces
            for (UIImageView* piece in [[theBoard pieces] objectEnumerator]) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    piece.transform = CGAffineTransformMakeRotation(0);
                }];
                
            }

        }

        
    }
    */
    
}

// MARK: Present Dead Pieces Picker View
- (void) presentDeadPiecesPickerView: (NSString*)pawnCurrentPos pawnObject:(UIImageView*)pawnObject {
    
    // Make sure dead pieces picker view is in the front
    [theBoard bringSubviewToFront:[theBoard deadPiecesPickerView]];
    
    // Create count vars to keep track of positions
    int xCount = 0;
    int yCount = 0;
    
    // Calculate the amount of pieces the superview can fit horizontaly and store it in maxPiecesX
    CGFloat maxPiecesX = ((UIView*)[theBoard deadPiecesPickerView]).frame.size.width / (pawnObject.frame.size.width + (((UIView*)[theBoard deadPiecesPickerView]).frame.size.height / 15));
    
    
    // Populate dead pieces picker view
    for (UIImageView* deadPiece in [[theBoard deadPieces] objectEnumerator]) {
        
        int t = (int)deadPiece.tag;
        
        // Add only if the dead piece is owned by the player that is choosing
        if (deadPiece.isUserInteractionEnabled) {
            
            // If piece is a pawn we are not going to add it
            if (t == 12 || t == 22 || t == 32 || t == 42 || t == 52 || t == 62 || t == 72 || t == 82 || t == 17 ||t == 27 || t == 37 || t == 47 || t == 57 || t == 67 || t == 77 || t == 87) {
                
            }
            else {
                
                // Piece is legal, add it
                
                // Update positions
                if (xCount > maxPiecesX) {
                    xCount = 0;
                    yCount+=1;
                }
                
                // Get frame of dead piece
                CGRect deadPieceFrm = deadPiece.frame;
                
                // Modify frame for dead pieces picker view
                deadPieceFrm.origin.y = (((UIView*)[theBoard deadPiecesPickerView]).frame.size.height / 8) + (yCount * deadPiece.frame.size.height);
                deadPieceFrm.origin.x = ((((UIView*)[theBoard deadPiecesPickerView]).frame.size.width / 15) * (xCount + 1)) + (xCount * deadPiece.frame.size.width);
                
                deadPiece.frame = deadPieceFrm;
                
                // Add piece to the dead pieces picker view
                [[theBoard deadPiecesPickerView] addSubview:deadPiece];
                
                xCount+=1;
                
            }
        }
    }
    
    // Now actually add the deadPiecePickerView to the superview by alphanating it
    [UIView animateWithDuration:0.5 animations:^{
        [[theBoard deadPiecesPickerView] setAlpha:1];
    }completion:^(BOOL finished) {
        
        if (odinIsOnline && isOdinsTurn) {
            
            // Select piece for odin
            UIImageView* pieceChoosen;
            int currentGreatestValue = 0;
            
            // Determine the best piece for odin to choose
            for (UIImageView* deadPiece in [[theBoard deadPieces] objectEnumerator]) {
                
                int t = (int)deadPiece.tag;

                if (deadPiece.isUserInteractionEnabled) {
                    
                    // If piece is a pawn we are not going to add it
                    if (t == 12 || t == 22 || t == 32 || t == 42 || t == 52 || t == 62 || t == 72 || t == 82 || t == 17 ||t == 27 || t == 37 || t == 47 || t == 57 || t == 67 || t == 77 || t == 87) {
                        
                    }
                    else {
                        // Find out if currentGreatest value is less than the value of this iteration
                        if (currentGreatestValue < [odin findPieceValue:(int)deadPiece.tag]) {
                            
                            currentGreatestValue = [odin findPieceValue:(int)deadPiece.tag];
                            
                            // Set the desired piece
                            pieceChoosen = deadPiece;
                            
                        }
                    }
                }
            }
            
            [UIView animateWithDuration:0.5 delay:0.75 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [pieceChoosen setAlpha:0];
            }completion:^(BOOL finished) {
                
                // Odin has chose a piece, complete the process
                [self deadPieceSelected:pieceChoosen];
                
            }];
        }
        
    }];
    
}

// MARK: Player Selected Dead Piece From Picker View
- (void) deadPieceSelected: (UIImageView*)deadPiece {
    
    // Make sure dead piece has superview then remove it from the superview
    if (deadPiece.superview != nil) {
        [deadPiece removeFromSuperview];
    }
    
    // Remove the dead pieces picker view from the superview by alphanation
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [[theBoard deadPiecesPickerView] setAlpha:0];
    }completion:^(BOOL finished) {
        
        // Finalize replacement process
        
        // Get grid key position from pawn that is being replaced
        NSArray *pawnTemp = [[theBoard pieces] allKeysForObject:pawnForReplacement];
        NSString *pawnKey = [pawnTemp firstObject];
        
        // Get key for dead piece so we can remove it from the dead pieces dictionary
        NSArray *deadTemp = [[theBoard deadPieces] allKeysForObject:deadPiece];
        NSString *deadKey = [deadTemp firstObject];
        
        // Remove pawn from alive pieces dictionary
        [[theBoard pieces] removeObjectForKey:pawnKey];
        
        // Remove dead piece from dead pieces dictionary
        [[theBoard deadPieces] removeObjectForKey:deadKey];
        
        // Add pawn to dead pieces array
        [[theBoard deadPieces] setObject:pawnForReplacement forKey:[NSString stringWithFormat:@"%d", (int)pawnForReplacement.tag]];
        
        // Add dead piece to alive pieces array
        [[theBoard pieces] setObject:deadPiece forKey:pawnKey];
        
        // Physically add deadPiece to board
        CGRect frameToSet = pawnForReplacement.frame;
        
        // Set the dead piece frame to its new frame which is the pawn that is being replaced's frame
        [deadPiece setFrame:frameToSet];

        
        // Remove pawn to replace (animated)
        [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [pawnForReplacement setAlpha:0];
        }completion:^(BOOL finished) {
            
            // Finaly remove pawn
            [pawnForReplacement removeFromSuperview];
            [pawnForReplacement setAlpha:1];
            
            // Set up dead piece so we can add it to the board
            [deadPiece setAlpha:0];
            [theBoard addSubview:deadPiece];
            
            // Add dead piece to the board (animated)
            [UIView animateWithDuration:0.25 delay:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [deadPiece setAlpha:1];
            }completion:^(BOOL finished) {
                
                // Finish up finally
                
                // Restore dead piece picker view
                for (UIImageView* someDeadPiece in [[theBoard deadPiecesPickerView] subviews]) {
                    [someDeadPiece removeFromSuperview];
                }
                
                // Reset vars as needed
                pawnForReplacement = nil;
                selectedPiece = nil;
                currentObjectKey = nil;
                
                // End turn here
                [self endTurn];
                
            }];

        }];
        
    }];
}



// MARK: Confirm Move
-(void) confirmMove {
    
    
    // Create previous object just in case the move is invalid
    // Piece that is being moved
    UIImageView* movingPiece = [theBoard pieces][lastPieceKey];
    
    // Piece that is being removed from board (may not exist)
    UIImageView* pieceToGetRidOf = [theBoard pieces][currentObjectKey];;
    
    
    if (lastPieceKey != nil) {
        [[theBoard pieces] removeObjectForKey:lastPieceKey];
    }
    
    [[theBoard pieces] removeObjectForKey:currentObjectKey];
    [[theBoard pieces] setObject:selectedPiece forKey:currentObjectKey];
   
    
    // Check to make sure the move is legal relative to the position of pieces on the board
    if ([self selfInducedCheckAnalysis] == false) {
        
        // NOTE: the cancel method which acually moves the pieces to their previous location is handled in the alert action
        
        // Reset behind the scenes grid pieces positons
        [[theBoard pieces] setObject:movingPiece forKey:lastPieceKey];
        if (pieceToGetRidOf != nil) {
            [[theBoard pieces] setObject:pieceToGetRidOf forKey:currentObjectKey];
        }
        else {
            [[theBoard pieces] removeObjectForKey:currentObjectKey];
        }
        
        // Display alert
        [self displayAlert:@"" message:@"You can't put your self in check!"];
        
        // Reset array
        [tempAvailPositions removeAllObjects];
        
        lastPieceKey = nil;
        
        return;
    }

    // Check for dead piece and if it exists put it in deadPiece array
    if (pieceToGetRidOf != nil) {
        [[theBoard deadPieces] setObject:pieceToGetRidOf forKey:[NSString stringWithFormat:@"%ld", (long)pieceToGetRidOf.tag]];
    }

    // Reset variables as needed
    lastPieceKey = nil;
    currentGridSpot.layer.borderWidth = 0;
    canSelectPiece = true;
    currentGridSpot = nil;
    lastPieceFrame = CGRectZero;
    lastPieceKey = nil;
    
    [cancelButton setAlpha:0];
    [confirmButton setAlpha:0];
    
    // Check if someone is in check
    if (![self oppenentInducedCheckAnalysis]) {
        
        // Check if there is a checkmate
        if ([self performCheckmateAnalysis]) {
            // GAME OVER!!
            
            // Display alert
            [self displayAlert:@"CHECKMATE" message:@"Game Over!"];
                
            // Reset array
            [tempAvailPositions removeAllObjects];
                
            return;
        }
        
        // Display alert
        [self displayAlert:@"Check" message:@""];
            
        // Reset array
        [tempAvailPositions removeAllObjects];
            
        return;
        
        
    };
    
    // Check if someone is in the endzone with a PAWN
    // Get selected piece tag and assign it to t
    int t = (int)selectedPiece.tag;
    if (t == 12 || t == 22 || t == 32 || t == 42 || t == 52 || t == 62 || t == 72 || t == 82 || t == 17 ||t == 27 || t == 37 || t == 47 || t == 57 || t == 67 || t == 77 || t == 87) {
        
        // Selected piece is pawn
        
        // Identify which side the pieces is on by getting the last index of its tag
        unichar charTag = [[NSString stringWithFormat:@"%d", t] characterAtIndex:1];
        NSString* tagY = [NSString stringWithCharacters:&charTag length:1];
        
        // Get y pos of currentObjectKey (grid position)
        unichar currentSpotKeyY = [currentObjectKey characterAtIndex:1];
        NSString* spotYPos = [NSString stringWithCharacters:&currentSpotKeyY length:1];
        
        // Check to see if the pawn is in the endzone
        if (([tagY isEqual:@"2"] && [spotYPos isEqual:@"8"]) || ([tagY isEqual:@"7"] && [spotYPos isEqual:@"1"])) {
            
            // Pawn is in the endzone
            
            // Check to see if player even has dead pieces
            BOOL hasDeadPieces = false;
            for (UIImageView* deadPiece in [[theBoard deadPieces] objectEnumerator]) {
                
                if (deadPiece.isUserInteractionEnabled) {
                    
                    int dpt = (int)deadPiece.tag;
                    
                    // Check to make sure dead piece is not a pawn
                    if (dpt == 12 || dpt == 22 || dpt == 32 || dpt == 42 || dpt == 52 || dpt == 62 || dpt == 72 || dpt == 82 || dpt == 17 ||dpt == 27 || dpt == 37 || dpt == 47 || dpt == 57 || dpt == 67 || dpt == 77 || dpt == 87) {
                        
                    }
                    else {
                        
                        // Piece is legal
                        hasDeadPieces = true;
                    }
                }
            }
            
            // If player has dead pieces we will display the picker view
            if (hasDeadPieces) {
                
                // Set pawn for replacement
                pawnForReplacement = selectedPiece;
                
                // Start the process to present the dead pieces picker view
                [self presentDeadPiecesPickerView:currentObjectKey pawnObject:selectedPiece];
                
                return;
            }
            
        }
        
    }
    
    pawnForReplacement = nil;
    selectedPiece = nil;
    currentObjectKey = nil;
    
    // Finish the turn
    [self endTurn];

    
}


// MARK: Cancel Move
-(void) cancelMove {
    
    
    [UIView animateWithDuration:0.75 animations:^{
        selectedPiece.frame = lastPieceFrame;
    }completion:^(BOOL finished){
        
        if (![theBoard.subviews containsObject:((UIImageView*)[theBoard pieces][currentObjectKey])]) {
            [theBoard addSubview:((UIImageView*)[theBoard pieces][currentObjectKey])];
        }
        canSelectPiece = true;
        selectedPiece = nil;
        currentObjectKey = nil;
        lastPieceFrame = CGRectZero;
        lastPieceKey = nil;
        currentGridSpot.layer.borderWidth = 0;
        currentGridSpot = nil;
        
    }];
    
    
    [confirmButton setAlpha:0];
    [cancelButton setAlpha:0];
}


// MARK: Available Spots for Piece
-(void) findAvailableSpots: (NSInteger)withTag pieceObjectPos:(NSString*)pieceObjectPos {
    
    switch (withTag) {
            
        case 11 :
            [self rookAvailableSpots:pieceObjectPos];
            break;
        case 21 :
            [self knightAvailableSpots:pieceObjectPos];
            break;
        case 31 :
            [self bishopAvailableSpots:pieceObjectPos];
            break;
        case 41 :
            [self kingAvailableSpots:pieceObjectPos];
            break;
        case 51 :
            [self queenAvailableSpots:pieceObjectPos];
            break;
        case 61 :
            [self bishopAvailableSpots:pieceObjectPos];
            break;
        case 71 :
            [self knightAvailableSpots:pieceObjectPos];
            break;
        case 81 :
            [self rookAvailableSpots:pieceObjectPos];
            break;
        case 12 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 22 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 32 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 42 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 52 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 62 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 72 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 82 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
            
            // Other side
            
        case 17 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 27 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 37 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 47 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 57 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 67 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 77 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 87 :
            [self pawnAvailableSpots:pieceObjectPos];
            break;
        case 18 :
            [self rookAvailableSpots:pieceObjectPos];
            break;
        case 28 :
            [self knightAvailableSpots:pieceObjectPos];
            break;
        case 38 :
            [self bishopAvailableSpots:pieceObjectPos];
            break;
        case 48 :
            [self queenAvailableSpots:pieceObjectPos];
            break;
        case 58 :
            [self kingAvailableSpots:pieceObjectPos];
            break;
        case 68 :
            [self bishopAvailableSpots:pieceObjectPos];
            break;
        case 78 :
            [self knightAvailableSpots:pieceObjectPos];
            break;
        case 88 :
            [self rookAvailableSpots:pieceObjectPos];
            break;
        
        

            

    }
    
    if (isOdinsTurn) {
        [odin passPositionsToOdin:tempAvailPositions];
    }
    
}

// MARK: Rook Available Spots
-(void) rookAvailableSpots: (NSString*)piecePosition {
    
    unichar xChar = [piecePosition characterAtIndex:0];
    unichar yChar = [piecePosition characterAtIndex:1];
    
    int xPos = [NSString stringWithCharacters:&xChar length:1].intValue;
    int yPos = [NSString stringWithCharacters:&yChar length:1].intValue;
    
    // Amount of spaces rook can go up
    int upSpaces = yPos - 1;
    
    // Amount of spaces rook can go down
    int downSpaces = 8 - yPos;
    
    // Amount of spaces rook can go left
    int leftSpaces = xPos - 1;
    
    // Amount of spaces rook can go right
    int rightSpaces = 8 - xPos;
    
    
    // Up
    for (int spaces = upSpaces; spaces >= 1; spaces-=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (spaces)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
    }
    
    // Down
    for (int spaces = 1; spaces <= downSpaces; spaces+=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + spaces)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
    }
    
    // Left
    for (int spaces = leftSpaces; spaces >= 1; spaces-=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
    }

    
    // Right
    for (int spaces = 1; spaces <= rightSpaces; spaces+=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + spaces), (yPos)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
    }
    
}

// MARK: Knight Available Spots
-(void) knightAvailableSpots: (NSString*)piecePosition {
    
    unichar xChar = [piecePosition characterAtIndex:0];
    unichar yChar = [piecePosition characterAtIndex:1];
    
    int xPos = [NSString stringWithCharacters:&xChar length:1].intValue;
    int yPos = [NSString stringWithCharacters:&yChar length:1].intValue;
    
    // down 2 right 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 2)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // down 2 left 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 2)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // up 2 right 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 2)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }

    
    // up 2 left 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 2)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }

    // left 2 up 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // left 2 down 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 2), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }

    
    // right 2 up 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }

    
    // right 2 down 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 2), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }


    
}

// MARK: Bishop Available Spots
-(void) bishopAvailableSpots: (NSString*)piecePosition {
    
    unichar xChar = [piecePosition characterAtIndex:0];
    unichar yChar = [piecePosition characterAtIndex:1];
    
    int xPos = [NSString stringWithCharacters:&xChar length:1].intValue;
    int yPos = [NSString stringWithCharacters:&yChar length:1].intValue;
    
    // Amount of spaces rook can go up
    int upSpaces = yPos - 1;
    
    // Amount of spaces rook can go down
    int downSpaces = 8 - yPos;
    
    // Amount of spaces rook can go left
    int leftSpaces = xPos - 1;
    
    // Amount of spaces rook can go right
    //int rightSpaces = 8 - xPos;
    
    
    // Up Right
    int upRightCount = 1;
    for (int spaces = upSpaces; spaces >= 1; spaces-=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + upRightCount), (spaces)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
        
        upRightCount+=1;
    }
    
    // Down Right
    int downRightCount = 1;
    for (int spaces = 1; spaces <= downSpaces; spaces+=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + downRightCount), (yPos + spaces)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
        
        downRightCount+=1;
    }
    
    // Left Up
    int leftUpCount = 1;
    for (int spaces = leftSpaces; spaces >= 1; spaces-=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (spaces), (yPos - leftUpCount)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
        
        leftUpCount+=1;
    }
    
    
    // Left Down
    int leftDownCount = 1;
    for (int spaces = 1; spaces <= downSpaces; spaces+=1) {
        
        if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]]).layer.borderColor = [UIColor greenColor].CGColor;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]] == 1) {
            break;
        }
        else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - spaces), (yPos + leftDownCount)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            break;
        }
        
        leftDownCount+=1;
    }

}

// MARK: King Available Spots
-(void) kingAvailableSpots: (NSString*)piecePosition {
    
    unichar xChar = [piecePosition characterAtIndex:0];
    unichar yChar = [piecePosition characterAtIndex:1];
    
    int xPos = [NSString stringWithCharacters:&xChar length:1].intValue;
    int yPos = [NSString stringWithCharacters:&yChar length:1].intValue;

    
    // down 1 right 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // down 1 left 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // up 1 right 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    
    // up 1 left 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // up 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    // down 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    
    // right 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    
    // left 1
    if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]] == 0) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]]).layer.borderColor = [UIColor greenColor].CGColor;
    }
    else if ([self checkSpotSelected:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]] == 2) {
        [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]];
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]]).layer.borderWidth = 2;
        ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos)]]).layer.borderColor = [UIColor orangeColor].CGColor;
    }

    
}

// MARK: Queen Available Spots
-(void) queenAvailableSpots: (NSString*)piecePosition {
    
    [self rookAvailableSpots:piecePosition];
    [self bishopAvailableSpots:piecePosition];
}

// MARK: Pawn Available Spots
-(void) pawnAvailableSpots: (NSString*)piecePosition {
    
    unichar xChar = [piecePosition characterAtIndex:0];
    unichar yChar = [piecePosition characterAtIndex:1];
    
    int xPos = [NSString stringWithCharacters:&xChar length:1].intValue;
    int yPos = [NSString stringWithCharacters:&yChar length:1].intValue;
    
    // Check side direction to go
    if (((UIImageView*)([theBoard pieces][piecePosition])).tag % 10 == 2) {
        // Top
        
        // Check if pawn can go down 1
        if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)])] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
            
            // Check if pawn can go down 2
            if (((UIImageView*)([theBoard pieces][piecePosition])).tag == (int)piecePosition.intValue) {
                // Pawn is in starting spot, piece can move two ahead
                
                if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos), (yPos + 2)])] == 0) {
                    [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 2)]];
                    ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 2)]]).layer.borderWidth = 2;
                    ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos + 2)]]).layer.borderColor = [UIColor greenColor].CGColor;
                }
                
            }
            
        }
        
        
        // Check if pawn can take out enemy down 1 and left 1
        if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)])] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            
        }
        
        // Check if pawn can take out enemy down 1 and right 1
        if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)])] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos + 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            
        }

        
    }
    else {
        // Bottom
        
        // Check if pawn can go up 1
        if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)])] == 0) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 1)]]).layer.borderColor = [UIColor greenColor].CGColor;
            
            // Check if pawn can go up 2
            if (((UIImageView*)([theBoard pieces][piecePosition])).tag == (int)piecePosition.intValue) {
                // Pawn is in starting spot, piece can move two ahead
                
                if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos), (yPos - 2)])] == 0) {
                    [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 2)]];
                    ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 2)]]).layer.borderWidth = 2;
                    ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos), (yPos - 2)]]).layer.borderColor = [UIColor greenColor].CGColor;
                }
                
            }

        }
        
        // Check if pawn can take out enemy up 1 and left 1
        if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)])] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos - 1), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            
        }
        
        // Check if pawn can take out enemy up 1 and right 1
        if ([self checkSpotSelected:([NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)])] == 2) {
            [tempAvailPositions addObject:[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]];
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]]).layer.borderWidth = 2;
            ((UIView*)[theBoard grid][[NSString stringWithFormat:@"%d%d", (xPos + 1), (yPos - 1)]]).layer.borderColor = [UIColor orangeColor].CGColor;
            
        }

        
    }
    
    
    

    
}

int analyzeForSelfCheck = false;

// MARK: Perform Self Induced Check Analysis
-(int) selfInducedCheckAnalysis {
    
    analyzeForSelfCheck = true;
    
    // After analysis of paths, is the move legal?
    int analysis = true;
    
    // Restore tempAvailPositions if it is Odins turn so Odin can make a fresh analysis
    if (isOdinsTurn) {
        [tempAvailPositions removeAllObjects];
    }
    
    
    // Loop through board to find pieces on the opposite team
    for (UIImageView* daPiece in [[theBoard pieces] objectEnumerator]) {
        
        
        if (daPiece.userInteractionEnabled == false) {
            // Opponents piece found
            
            NSArray *temp = [[theBoard pieces] allKeysForObject:daPiece];
            NSString *key = [temp lastObject];
            
            // Get all opponent spots they can reach
            [self findAvailableSpots:daPiece.tag pieceObjectPos:key];
        }
    }
    
    
    // Loop through pieces array see if the king is in jepordy
    for (NSString* posKey in tempAvailPositions) {
        
        if (((UIImageView*)[theBoard pieces][posKey]).tag == 58 && ((UIImageView*)[theBoard pieces][posKey]).userInteractionEnabled == true) {
            // Your king is in jepordy
            analysis = false;
        }
        else if (((UIImageView*)[theBoard pieces][posKey]).tag == 41 && ((UIImageView*)[theBoard pieces][posKey]).userInteractionEnabled == true) {
            // Your king is in jepordy
            analysis = false;
        }
        

        
        ((UIView*)[theBoard grid][posKey]).layer.borderWidth = 0;

    }
    
    
    
    analyzeForSelfCheck = false;
    
    return analysis;
    
}

// MARK: Perform Oppenent Induced Check Analysis
-(int) oppenentInducedCheckAnalysis {
    
    // After analysis of paths, does this move put the other team in check?
    int analysis = true;
    
    // Create copy of temp avail positions so the positions in this copy can be removed from the original and therefor updated
    // Used when perfoming checkmate analysis
    NSMutableArray* copyOfTempAvailPositions = [tempAvailPositions mutableCopy];
    
    
    // Loop through board to find pieces on the same team
    for (UIImageView* daPiece in [[theBoard pieces] objectEnumerator]) {
        
        
        if (daPiece.userInteractionEnabled == true) {
            // Ally piece found
            
            NSArray *temp = [[theBoard pieces] allKeysForObject:daPiece];
            NSString *key = [temp lastObject];
            
            

            // Get all opponent spots they can reach
            [self findAvailableSpots:daPiece.tag pieceObjectPos:key];
        }
    }
    
    
    // Loop through pieces array see if the king is in jepordy
    for (NSString* posKey in tempAvailPositions) {
        
        ((UIView*)[theBoard grid][posKey]).layer.borderWidth = 0;
        
        
        // Check to make sure a position is not carried over from the old copy
        if ([copyOfTempAvailPositions count] > 0) {
            if ([copyOfTempAvailPositions containsObject:posKey]) {
                [copyOfTempAvailPositions removeObject:posKey];
                continue;
            }
        }
        
        if (((UIImageView*)[theBoard pieces][posKey]).tag == 58 && ((UIImageView*)[theBoard pieces][posKey]).userInteractionEnabled == false) {
            // Your king is in jepordy
            analysis = false;
        }
        else if (((UIImageView*)[theBoard pieces][posKey]).tag == 41 && ((UIImageView*)[theBoard pieces][posKey]).userInteractionEnabled == false) {
            // Your king is in jepordy
            analysis = false;
        }
        
        
    }
    
    
    
    return analysis;
    
}

int performingCheckmateAnalysis = false;

// MARK: Perform Checkmate Analysis
-(int) performCheckmateAnalysis {
    
    int analysis = false;
    
    // Clear tempAvailPositions
    [tempAvailPositions removeAllObjects];
    
    // Create copy of pieces array so that we dont mutate the real pieces array while its being enumerated
    NSMutableDictionary* tempPiecesArray = [[theBoard pieces] copy];
    
    // Create array to store the success of the paths being analyzed
    NSString* successPathsString = @"false";
    
    // Create array to store the pieces that were removed in the checkmate analysis process so they can be reset and replaced at the end
    NSString* removedPieceKey;
    
    NSString* lastRemovedKey = @"1";
    
    // Loop through board to find pieces on the opposite team
    for (UIImageView* daPiece in [tempPiecesArray objectEnumerator]) {
        

        if (daPiece.userInteractionEnabled == false) {
            // Opponents piece found
            
            
            NSArray *temp = [[theBoard pieces] allKeysForObject:daPiece];
            NSString *key = [temp lastObject];
            
            if (key == nil) {
                continue;
            }
            
            // Tell the check positions method to togle its results
            performingCheckmateAnalysis = true;
            
            // Get all opponent spots they can reach
            [self findAvailableSpots:daPiece.tag pieceObjectPos:key];
            
            // Untogle
            performingCheckmateAnalysis = false;

            // Create copy of tempAvailPositions so we can mutalate the real tempAvailPositions array while still looping through it
            NSMutableArray* copyOfTempAvailPositions = [tempAvailPositions copy];
            
            // Loop through copy of temp avail positions to see if a piece can sieze the checkmate
            for (NSString* availablePosition in copyOfTempAvailPositions) {
                
                
                // Get x y positions
                unichar xChar = [availablePosition characterAtIndex:0];
                unichar yChar = [availablePosition characterAtIndex:1];
                NSString* xPos = [NSString stringWithCharacters:&xChar length:1];
                NSString* yPos = [NSString stringWithCharacters:&yChar length:1];
                
                // Make sure spot is on the board
                if ((int)xPos.intValue > 8 || (int)xPos.intValue < 1) { continue; }
                if ((int)yPos.intValue > 8 || (int)yPos.intValue < 1) { continue; }
                
                if ([[copyOfTempAvailPositions lastObject] isEqual:availablePosition]) {
                    lastRemovedKey = availablePosition;
                }
                
                // Create newKey to advance through the available positions
                NSArray *newTemp = [[theBoard pieces] allKeysForObject:daPiece];
                NSString *newKey = [newTemp firstObject];
                
                
                // Create object to store the piece that may or may not be being removed (may not exist)
                UIImageView* pieceToRemove = [theBoard pieces][availablePosition];
                int pieceWasRemoved = false;
                
                // Check to see if there is a piece to be removed
                if (pieceToRemove != nil) {
                    removedPieceKey = availablePosition;
                    [[theBoard pieces] removeObjectForKey:availablePosition];
                    pieceWasRemoved = true;
                }
                
                // Set and remove piece so opponentInducedCheckAnalysis can begin
                // Remove at old position if the testing piece is there and not a piece that has been previously removed for analysis
                if (![removedPieceKey isEqual:newKey]) {
                    // Remove
                    if (newKey != nil) {
                        [[theBoard pieces] removeObjectForKey:newKey];
                    }
                }
                
                // Set new position of testing piece
                [[theBoard pieces] setObject:daPiece forKey:availablePosition];
                
                
                                
                // Perform analysis with these new positions and store it in the success paths string
                if ([self oppenentInducedCheckAnalysis]) {
                    // Store true
                    successPathsString = [successPathsString stringByAppendingString:@"true"];
                }
                else {
                    // Store false
                    successPathsString = [successPathsString stringByAppendingString:@"false"];
                }
                
                // Reset tempAvailPositions array for next iteration
                [tempAvailPositions removeAllObjects];

                
                // Reset test piece
                [[theBoard pieces] removeObjectForKey:availablePosition];
                [[theBoard pieces] setObject:daPiece forKey:key];
                
                // Restore removed pieces if there was any
                if (pieceWasRemoved == true) {
                    
                    // Add piece back
                    [[theBoard pieces] setObject:pieceToRemove forKey:removedPieceKey];
                }
                
                
            }
            
            
            
            // Remove last location where the testing piece was
            if (((UIImageView*)[theBoard pieces][lastRemovedKey]).tag == daPiece.tag) {
                [[theBoard pieces] removeObjectForKey:lastRemovedKey];
                
                // Put test piece back in original spot
                [[theBoard pieces] setObject:daPiece forKey:key];
            }
            
            
            
            // Clear temp avail positions array
            [tempAvailPositions removeAllObjects];
            
            // Reset removedPieceKey for next piece
            removedPieceKey = @"";
        }
    }
    
    
    // Check to see if any of the success paths were able to sieze the checkmate
    if ([successPathsString rangeOfString:@"true"].location == NSNotFound) {
        analysis = true;
    }
    else {
        analysis = false;
    }
    
    performingCheckmateAnalysis = false;
    
    return analysis;
}


// MARK: Play ODIN set up
-(void) playOdin {
    
    // Make sure start menu clips subviews to bounds
    [startMenu setClipsToBounds:true];
    
    // Create odin label
    UILabel* odinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, startMenu.frame.size.height/6, startMenu.frame.size.width, startMenu.frame.size.height/3)];
    [odinLabel setText:@"O D I N"];
    [odinLabel setAlpha:0];
    [odinLabel setFont:[UIFont fontWithName:@"Vonique 64.ttf" size:50]];
    [odinLabel setFont: [odinLabel.font fontWithSize: 30]];
    [odinLabel setTextAlignment:NSTextAlignmentCenter];
    
    // Create comming online label
    UILabel* commingOnlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, startMenu.frame.size.height/1.5, startMenu.frame.size.width, startMenu.frame.size.height/7)];
    [commingOnlineLabel setText:@"C O M M I N G   O N L I N E"];
    [commingOnlineLabel setAlpha:0];
    [commingOnlineLabel setFont:[UIFont fontWithName:@"Vonique 64.ttf" size:12]];
    [commingOnlineLabel setFont: [commingOnlineLabel.font fontWithSize: 12]];
    [commingOnlineLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    // Add to superview
    [startMenu addSubview:odinLabel];
    [startMenu addSubview:commingOnlineLabel];
    
    // Create loading line
    UIView* loadingLine = [[UIView alloc] init];
    [loadingLine setBackgroundColor:[UIColor blackColor]];
    [loadingLine setFrame:CGRectMake(0, startMenu.frame.size.height/2, 0, 4)];
    
    [startMenu addSubview:loadingLine];

    // Animation series
    [UIView animateWithDuration:0.5 animations:^{
        [playOdinButton setAlpha:0];
        [playLocalButton setAlpha:0];
        [chessTitleLabel setAlpha:0];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [odinLabel setAlpha:1];
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1.5 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [commingOnlineLabel setAlpha:1];
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:2 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    loadingLine.frame = CGRectMake(0, startMenu.frame.size.height/2, self.view.frame.size.width, 4);
                }completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:1.25 delay:1.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [odinLabel setAlpha:0];
                        [commingOnlineLabel setAlpha:0];
                        loadingLine.frame = CGRectMake(startMenu.frame.size.width/2, startMenu.frame.size.height/2, 0, 4);
                    }completion:^(BOOL finished) {

                        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            [startMenu setAlpha:0];
                        }completion:nil];
                        
                    }];
                    
                }];
            }];
            
        }];

    }];
    
    
    
}


// MARK: Display alert
-(void) displayAlert: (NSString*)title message:(NSString*)message {
    
    NSString *alertTitle = title;
    NSString *alertMessage = message;
    NSString *alertOkButtonText = @"OK";
    NSString *alertCancelButtonText = @"Cancel";

    
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:alertOkButtonText
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             
                                                             if ([message isEqual:@"You can't put your self in check!"]) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [self cancelMove];
                                                                 });
                                                             }
                                                             
                                                             if ([message isEqual:@"Game Over!"]) {
                                                                 // Reset game
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [self gameOverReset];
                                                                 });
                                                             }
                                                             
                                                             if ([title isEqual:@"Check"]) {
                                                                 // End turn on touch
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [self endTurn];
                                                                 });
                                                             }

                                                             if ([message isEqual:@"No moves can be made by Odin"]) {
                                                                 // Reset game
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [self gameOverReset];
                                                                 });
                                                                 
                                                             }
                                                             
                                                             if ([title isEqual:@"Go Home?"]) {
                                                                 // Take the user to main screen
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     
                                                                     odinIsOnline = false;
                                                                     isOdinsTurn = false;
                                                                     
                                                                     [UIView animateWithDuration:0.75 animations:^{
                                                                         [startMenu setAlpha:1];
                                                                         [chessTitleLabel setAlpha:1];
                                                                         [playOdinButton setAlpha:1];
                                                                         [playLocalButton setAlpha:1];
                                                                     }completion:^(BOOL finished) {
                                                                         [self gameOverReset];
                                                                         [self endTurn];
                                                                     }];

                                                                 });
                                                                 
                                                             }
                                                             
                                                             
                                                             
                                                             
                                                         }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:alertCancelButtonText
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
        // Add cancel action if user clicked go home
        if ([title isEqual:@"Go Home?"]) {
            [alertController addAction:actionCancel];
        }
    
        [alertController addAction:actionOk];
    
        id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if([rootViewController isKindOfClass:[UINavigationController class]])
        {
            rootViewController = ((UINavigationController *)rootViewController).viewControllers.firstObject;
        }
        if([rootViewController isKindOfClass:[UITabBarController class]])
        {
            rootViewController = ((UITabBarController *)rootViewController).selectedViewController;
        }
        [rootViewController presentViewController:alertController animated:YES completion:nil];
        
        //[self presentViewController:alertController animated:YES completion:nil];
    
}

// MARK: Game Over, Reset Game
- (void) gameOverReset {
    
    // RESET GAME SETTINGS
    
    // Create copys of dictionarys
    NSMutableDictionary* piecesCopy = [[theBoard pieces] copy];
    NSMutableDictionary* deadPiecesCopy = [[theBoard deadPieces] copy];

    // Reset pieces on board for a nice fresh start! :)
    for (UIImageView* piece in [piecesCopy objectEnumerator]) {
        
        // Get key/position for piece
        NSArray *temp = [[theBoard pieces] allKeysForObject:piece];
        NSString *key = [temp firstObject];
        
        if (key != nil) {
            // Remove existing key/position
            [[theBoard pieces] removeObjectForKey:key];
            
            // Restore original position
            [[theBoard pieces] setObject:piece forKey:[NSString stringWithFormat:@"%ld", (long)piece.tag]];
        }
        else {
            // Restore original position
            [[theBoard pieces] setObject:piece forKey:[NSString stringWithFormat:@"%ld", (long)piece.tag]];
        }
        
        // Remove from super view
        if ([[theBoard subviews] containsObject:piece]) {
            [piece removeFromSuperview];
        }
        
    }
    
    
    // Do the same for the dead pieces
    for (UIImageView* piece in [deadPiecesCopy objectEnumerator]) {
        
        // Restore original position
        [[theBoard pieces] setObject:piece forKey:[NSString stringWithFormat:@"%ld", (long)piece.tag]];
    }
    
    [[theBoard deadPieces] removeAllObjects];
    
    // Make sure all spots are not highlighted
    for (UIView* spot in [[theBoard grid] objectEnumerator]) {
        spot.layer.borderWidth = 0;
    }

    
    // Tell ChessBoard to re add the pieces
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetGame"
                                                        object:self];
    
    pieceCurrentlySelected = false;
    canSelectPiece = true;
    
    [cancelButton setAlpha:0];
    [confirmButton setAlpha:0];
    
    
    [tempAvailPositions removeAllObjects];
    
    //theBoard = [[ChessBoard alloc] initWithFrame:self.view.bounds];
    
    [self endTurn];

}


// Hide status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}



@end
