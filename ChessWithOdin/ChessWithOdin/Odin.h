//
//  Odin.h
//  Objective-C Playground
//
//  Created by Garret Kaye on 1/19/17.
//  Copyright © 2017 Garret Kaye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheBoard.h"
#import "ViewController.h"


@interface Odin : NSObject


- (void) doSomething: (NSMutableDictionary*)boardPieces grid:(NSMutableDictionary*)grid;
- (void) passPositionsToOdin: (NSMutableArray*)tempAvailPos;
- (int) findPieceValue: (int)withTag;

@end

