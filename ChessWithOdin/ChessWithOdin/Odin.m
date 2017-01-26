//
//  Odin.m
//  Objective-C Playground
//
//  Created by Garret Kaye on 1/19/17.
//  Copyright © 2017 Garret Kaye. All rights reserved.
//

// ODIN
// CHESS AI

#import "Odin.h"

ViewController* ovc;
NSMutableDictionary* theChessBoardPieces;
NSMutableDictionary* theChessBoardGrid;


NSMutableArray* odinTempAvailPositions;
NSMutableDictionary* piecesAndPositions;

int shouldDoubleCheck = false;

@implementation Odin

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self odinInit];
    }
    return self;
}


- (void) odinInit {
    // Set up here
    printf("ODIN ONLINE");
    
    
    ovc = [ViewController alloc];
    piecesAndPositions = [[NSMutableDictionary alloc] init];


}


- (void) doSomething: (NSMutableDictionary*)boardPieces grid:(NSMutableDictionary*)grid {
    // Initiate odins move
    
    // Assign the chess board pieces
    if (theChessBoardPieces == nil || theChessBoardPieces != boardPieces) {
        theChessBoardPieces = boardPieces;
    }
    
    // Assign the grid spots
    if (theChessBoardGrid == nil) {
        theChessBoardGrid = grid;
    }
    
    // Start move process
    [self performChessBoardAnalysis];
    [self determineWhereToGo];
}


- (void) passPositionsToOdin: (NSMutableArray*)tempAvailPos {
    // Called when vc looks for available positions for a piece and then passes them here for Odin
    
    odinTempAvailPositions = tempAvailPos;
}

// Method that finds value of piece so odin can make good decisions
- (int) findPieceValue: (int)withTag {
    
    int pieceValue = 0;
    
    
    switch (withTag) {
            
            
        case 11 :
            pieceValue = 8;
            break;
        case 21 :
            pieceValue = 4;
            break;
        case 31 :
            pieceValue = 6;
            break;
        case 41 :
            pieceValue = 12;
            break;
        case 51 :
            pieceValue = 10;
            break;
        case 61 :
            pieceValue = 6;
            break;
        case 71 :
            pieceValue = 4;
            break;
        case 81 :
            pieceValue = 8;
            break;
        case 12 :
            pieceValue = 2;
            break;
        case 22 :
            pieceValue = 2;
            break;
        case 32 :
            pieceValue = 2;
            break;
        case 42 :
            pieceValue = 2;
            break;
        case 52 :
            pieceValue = 2;
            break;
        case 62 :
            pieceValue = 2;
            break;
        case 72 :
            pieceValue = 2;
            break;
        case 82 :
            pieceValue = 2;
            break;
            
            // Other side
            
        case 17 :
            pieceValue = 2;
            break;
        case 27 :
            pieceValue = 2;
            break;
        case 37 :
            pieceValue = 2;
            break;
        case 47 :
            pieceValue = 2;
            break;
        case 57 :
            pieceValue = 2;
            break;
        case 67 :
            pieceValue = 2;
            break;
        case 77 :
            pieceValue = 2;
            break;
        case 87 :
            pieceValue = 2;
            break;
        case 18 :
            pieceValue = 8;
            break;
        case 28 :
            pieceValue = 4;
            break;
        case 38 :
            pieceValue = 6;
            break;
        case 48 :
            pieceValue = 10;
            break;
        case 58 :
            pieceValue = 12;
            break;
        case 68 :
            pieceValue = 6;
            break;
        case 78 :
            pieceValue = 4;
            break;
        case 88 :
            pieceValue = 8;
            break;
            
            
    }
    
    
    return pieceValue;
}

// MARK: Perform Board Analysis
-(void) performChessBoardAnalysis {
    
    // Clear tempAvailPositions
    [odinTempAvailPositions removeAllObjects];
    [piecesAndPositions removeAllObjects];
    
    // Create copy of pieces array so that we dont mutate the real pieces array while its being enumerated
    NSMutableDictionary* tempPiecesArray = [theChessBoardPieces copy];
    
    
    // Create array to store the pieces that were removed in the checkmate analysis process so they can be reset and replaced at the end
    NSString* removedPieceKey;
    
    NSString* lastRemovedKey = @"1";
    
    // Loop through board to find pieces on the opposite team
    for (UIImageView* daPiece in [tempPiecesArray objectEnumerator]) {
        
        
        if (daPiece.userInteractionEnabled == true) {
            // Odins piece found
            
            
            NSArray *temp = [theChessBoardPieces allKeysForObject:daPiece];
            NSString *key = [temp lastObject];
            
            if (key == nil) {
                continue;
            }
            
            // Get all opponent spots they can reach
            [ovc findAvailableSpots:daPiece.tag pieceObjectPos:key];
            
            
            // Create copy of tempAvailPositions so we can mutalate the real tempAvailPositions array while still looping through it
            NSMutableArray* copyOfTempAvailPositions = [odinTempAvailPositions copy];
            
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
                NSArray *newTemp = [theChessBoardPieces allKeysForObject:daPiece];
                NSString *newKey = [newTemp firstObject];
                
                
                // Create object to store the piece that may or may not be being removed (may not exist)
                UIImageView* pieceToRemove = theChessBoardPieces[availablePosition];
                int pieceWasRemoved = false;
                
                // Check to see if there is a piece to be removed
                if (pieceToRemove != nil) {
                    removedPieceKey = availablePosition;
                    [theChessBoardPieces removeObjectForKey:availablePosition];
                    pieceWasRemoved = true;
                }
                
                // Set and remove piece so opponentInducedCheckAnalysis can begin
                // Remove at old position if the testing piece is there and not a piece that has been previously removed for analysis
                if (![removedPieceKey isEqual:newKey]) {
                    // Remove
                    if (newKey != nil) {
                        [theChessBoardPieces removeObjectForKey:newKey];
                    }
                }
                
                // Set new position of testing piece
                [theChessBoardPieces setObject:daPiece forKey:availablePosition];
                
                // Check to see if move puts odin in check
                if ([ovc selfInducedCheckAnalysis] && theChessBoardGrid[availablePosition] != nil) {
                    // Store move in dictionary
                    [piecesAndPositions setObject:daPiece forKey:availablePosition];
                }
                
                // Reset tempAvailPositions array for next iteration
                [odinTempAvailPositions removeAllObjects];
                
                // Reset test piece
                [theChessBoardPieces removeObjectForKey:availablePosition];
                [theChessBoardPieces setObject:daPiece forKey:key];
                
                // Restore removed pieces if there was any
                if (pieceWasRemoved == true) {
                    
                    // Add piece back
                    [theChessBoardPieces setObject:pieceToRemove forKey:removedPieceKey];
                }
                
                
            }
            
            
            
            // Remove last location where the testing piece was
            if (((UIImageView*)theChessBoardPieces[lastRemovedKey]).tag == daPiece.tag) {
                [theChessBoardPieces removeObjectForKey:lastRemovedKey];
                
                // Put test piece back in original spot
                [theChessBoardPieces setObject:daPiece forKey:key];
            }
            
            
            
            // Clear temp avail positions array
            [odinTempAvailPositions removeAllObjects];
            
            // Reset removedPieceKey for next piece
            removedPieceKey = @"";
        }
    }
        
}


// MARK: Determine where odin should move his pieces
- (void) determineWhereToGo {
    
    
    // Create array to store availble spots where odin can take out an enemy
    NSMutableArray* enemySpots = [[NSMutableArray alloc] init];
    
    // Create var to store the position Odin wishes to move piece to as well as the piece he is moving
    UIView* desiredSpot;
    UIImageView* pieceToMove;
    
    // Check if the dictionary has values
    if (piecesAndPositions.count > 0) {
        for (NSString* key in piecesAndPositions.keyEnumerator) {
            
            if (theChessBoardPieces[key] != nil) {
                if (((UIImageView*)theChessBoardPieces[key]).userInteractionEnabled == false) {
                    [enemySpots addObject:key];
                }
            }
            
        }
    }
    else {
        // No moves could be made, find out why
        // Check if odin has been checkmated
        if ([ovc performCheckmateAnalysis]) {
            
            // Odin has lost
            // This will be handled by the vc "confirmMove()" method later
            
        }
        else {
            // Unlikely scenario where Odin is not in check but rather he can not move anywhere otherwise he will be in check
            if (shouldDoubleCheck == false) {
                shouldDoubleCheck = true;
                [self performChessBoardAnalysis];
                [self determineWhereToGo];
            }
            else {
                [ovc displayAlert:@"Game Over!" message:@"No moves can be made by Odin"];
                shouldDoubleCheck = false;
            }
        }

        return;
    }
    
    if (enemySpots.count > 0) {
        
        // Create var to store the greatest current value in the array
        int currentGreatestValue = 0;
        
        // Loop through enemy spots to find a course of action to carry out
        for (NSString* value in enemySpots) {
            
            // Find out if currentGreatest value is less than the value of this iteration
            // Get the piece from the array and determine its value
            if (currentGreatestValue < [self findPieceValue:(int)((UIImageView*)theChessBoardPieces[value]).tag]) {
                currentGreatestValue = [self findPieceValue:(int)((UIImageView*)theChessBoardPieces[value]).tag];
                
                // Set the desired piece and spot to the greatest element Odin can take out
                pieceToMove  = ((UIImageView*)piecesAndPositions[value]);
                desiredSpot  = [theChessBoardGrid objectForKey:value];
                
            }
            
            
        }

    }
    else {
        // No enemys pieces can be taken, take random spot for now
        // Create random index
        NSUInteger randomIndex = arc4random() % [piecesAndPositions count];
        
        // Access it
        // Set the desired piece and desired position spot
        NSString* gridPositionKey = [[piecesAndPositions allKeys] objectAtIndex:randomIndex];
        
        
        pieceToMove  = ((UIImageView*)piecesAndPositions[gridPositionKey]); //[[theChessBoard pieces] objectForKey:[NSString stringWithFormat: @"%ld", (long)((UIImageView*)self.piecesAndPositions[gridPositionKey]).tag]];
        desiredSpot  = [theChessBoardGrid objectForKey:gridPositionKey];
        
        
    }
    
    
    // Move Odins desired piece to desired spot
    [self moveOdinsPiece:desiredSpot selectedPiece:pieceToMove];
}


// MARK: Spot Tapped
- (void)moveOdinsPiece:(UIView *)spot selectedPiece:(UIImageView*)selectedPiece {
    
    NSArray *temp = [theChessBoardGrid allKeysForObject:spot];
    NSString *key = [temp lastObject];
    
    NSArray *pieceTemp = [theChessBoardPieces allKeysForObject:selectedPiece];
    NSString *lastKey = [pieceTemp lastObject];
    
    //if ([self checkSpotSelected:key] == 1) { [tempAvailPositions removeAllObjects]; return; }
    
    // TODO: Check if spot is a place the piece has the ability to move too
    
    // Clear temp array for next piece to be selected
    [odinTempAvailPositions removeAllObjects];
    
    // If spot is not valid return
    //if (spotIsValid == false) { return; }
    
    // Check if spot is occupied, if so remove the piece occupying it
    if (theChessBoardPieces[key] == nil) {
        
    }
    else {
        [((UIImageView*)theChessBoardPieces[key]) removeFromSuperview];
    }
    
    // Remove visual of temporary positions
    for (UIView* gridSpot in [theChessBoardGrid objectEnumerator]) {
        
        gridSpot.layer.borderWidth = 0;
        
    }
    
    // Rect to go to
    
    CGRect rectToGoTo = CGRectMake(0, 0, selectedPiece.frame.size.width, selectedPiece.frame.size.height);
    rectToGoTo.origin.x = (spot.frame.origin.x) + ((spot.superview.frame.size.width/8) - (spot.superview.frame.size.width/10)) / 2;
    rectToGoTo.origin.y = (spot.frame.origin.y) + ((spot.superview.frame.size.height/8) - (spot.superview.frame.size.height/10)) / 2;
    
    [UIView animateWithDuration:0.75 animations:^{
        selectedPiece.frame = rectToGoTo;
    }completion:^(BOOL finished){
        
        // Pass data to vc so we can confirm the move and set everything
        [ovc posDataFromOdin:lastKey oSelectedPiece:selectedPiece oCurrentObjectKey:key];
        
        [ovc confirmMove];
        
        // Check HERE if odin put player in check
        /*
        if (![ovc oppenentInducedCheckAnalysis]) {
            
            // Check HERE if it is actually a checkmate
            if ([ovc performCheckmateAnalysis]) {
                [ovc displayAlert:@"CHECKMATE" message:@"Game Over!"];
            }
            else {
                [ovc displayAlert:@"Check" message:@""];
            }
            
        }
         */
        
    }];
    
}

@end
    
    
