//
//  SetUp.h
//  Objective-C Playground
//
//  Created by Garret Kaye on 1/15/17.
//  Copyright © 2017 Garret Kaye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChessBoard : UIView

@property NSMutableDictionary* grid;
@property NSMutableDictionary* pieces;
@property NSMutableDictionary* deadPieces;
@property UIView* deadPiecesPickerView;


@end
