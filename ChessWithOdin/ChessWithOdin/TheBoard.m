//
//  SetUp.m
//  Objective-C Playground
//
//  Created by Garret Kaye on 1/15/17.
//  Copyright © 2017 Garret Kaye. All rights reserved.
//

// THIS IS THE MODEL AND VIEW

#import "TheBoard.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ChessBoard

ViewController* vc;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Init dead pieces picker view
        self.deadPiecesPickerView = [[UIView alloc] init];
        
        self.grid = [[NSMutableDictionary alloc] init];
        self.pieces = [[NSMutableDictionary alloc] init];
        self.deadPieces = [[NSMutableDictionary alloc] init];
        
        [self initalizePiecesDictionary];
        [self layoutChessBoard];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReset:)
                                                     name:@"ResetGame"
                                                   object:nil];
        
        
    }
    return self;
}


-(void)handleReset:(NSNotification *)notification {
    [self addPiecesToBoard];
}


-(void) initalizePiecesDictionary {
    
    double rambo = ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(1-0)+0;
    
    if (rambo >= 0.50) {
        
        // Black
        self.pieces[@"11"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookB"]];
        self.pieces[@"21"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightB"]];
        self.pieces[@"31"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopB"]];
        self.pieces[@"41"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KingB"]];
        self.pieces[@"51"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"QueenB"]];
        self.pieces[@"61"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopB"]];
        self.pieces[@"71"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightB"]];
        self.pieces[@"81"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookB"]];
        
        self.pieces[@"12"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"22"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"32"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"42"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"52"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"62"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"72"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"82"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        
        // White
        self.pieces[@"17"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"27"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"37"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"47"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"57"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"67"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"77"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"87"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        
        self.pieces[@"18"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookW"]];
        self.pieces[@"28"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightW"]];
        self.pieces[@"38"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopW"]];
        self.pieces[@"48"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"QueenW"]];
        self.pieces[@"58"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KingW"]];
        self.pieces[@"68"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopW"]];
        self.pieces[@"78"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightW"]];
        self.pieces[@"88"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookW"]];
        
    }
    else {
        
        // White
        self.pieces[@"11"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookW"]];
        self.pieces[@"21"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightW"]];
        self.pieces[@"31"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopW"]];
        self.pieces[@"41"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KingW"]];
        self.pieces[@"51"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"QueenW"]];
        self.pieces[@"61"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopW"]];
        self.pieces[@"71"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightW"]];
        self.pieces[@"81"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookW"]];
        
        self.pieces[@"12"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"22"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"32"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"42"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"52"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"62"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"72"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        self.pieces[@"82"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnW"]];
        
        // Black
        self.pieces[@"17"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"27"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"37"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"47"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"57"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"67"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"77"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        self.pieces[@"87"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PawnB"]];
        
        self.pieces[@"18"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookB"]];
        self.pieces[@"28"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightB"]];
        self.pieces[@"38"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopB"]];
        self.pieces[@"48"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"QueenB"]];
        self.pieces[@"58"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KingB"]];
        self.pieces[@"68"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BishopB"]];
        self.pieces[@"78"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"KnightB"]];
        self.pieces[@"88"] = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RookB"]];
        
    }
    
    
    
    
}

-(void) layoutChessBoard {
    
    vc = [[ViewController alloc] init];
    
    
    CGRect boardFrm = [[UIScreen mainScreen] bounds];

    if (boardFrm.size.width > boardFrm.size.height) {
        boardFrm.size.height -= (boardFrm.size.height/10);
        boardFrm.origin.x = (boardFrm.size.width - boardFrm.size.height) / 2;
        
        boardFrm.size.width = boardFrm.size.height;
        boardFrm.origin.y = (boardFrm.size.height/10)/2;
        
    }
    else {
        boardFrm.size.width -= (boardFrm.size.width/10);
        boardFrm.origin.y = (boardFrm.size.height - boardFrm.size.width) / 2;
        
        boardFrm.size.height = boardFrm.size.width;
        boardFrm.origin.x = (boardFrm.size.width/10)/2;
    }
    
   
    
    [self setFrame:boardFrm];
    
    
    int squareSpotYPos = 0;
    int squareSpotXPos = 0;
    bool alternatePattern = false;
    int yAxisLoc = 1;
    int xAxisLoc = 0;
    
    for (int i = 1; i < 65; i += 1) {
        
        CGRect squareSpotFrm = CGRectMake(squareSpotXPos, squareSpotYPos, boardFrm.size.width/8, boardFrm.size.height/8);
        
        UIView *squareSpot = [[UIView alloc] initWithFrame:squareSpotFrm];
        
        UITapGestureRecognizer* squareSpotTapped = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleSpotTapped:)];
        
        [squareSpot addGestureRecognizer:squareSpotTapped];
        
        if ((i % 2) == 0) {
            // even
            if (alternatePattern == false) { squareSpot.backgroundColor = [UIColor brownColor]; }
            
            else { squareSpot.backgroundColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)181/255 alpha:(CGFloat)1]; }
            
        }
        else {
            // odd
            if (alternatePattern == false) { squareSpot.backgroundColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)181/255 alpha:(CGFloat)1]; }
            else { squareSpot.backgroundColor = [UIColor brownColor]; }
        }
        
        squareSpotXPos += boardFrm.size.width/8;
        
        [squareSpot setFrame:squareSpotFrm];
        [self addSubview:squareSpot];
        
        squareSpot.tag = i;
        
        xAxisLoc += 1;
        
        [self.grid setObject:(id)squareSpot forKey:[NSString stringWithFormat: @"%d%d", xAxisLoc, yAxisLoc]];
        
        if ((i % 8) == 0) {
            squareSpotYPos += boardFrm.size.height/8;
            squareSpotXPos = 0;
            yAxisLoc += 1;
            xAxisLoc = 0;
            
            if (alternatePattern == false) { alternatePattern = true; }
            else { alternatePattern = false; }
        }
        
    }
    

    // Add the pieces to the board in an orderly fashion
    [self addPiecesToBoard];
    
    //  Set up dead pieces picker view
    [self deadPiecesPickerViewSetUp];
    

}

- (void) deadPiecesPickerViewSetUp {
    
    // Set up the picker view frame
    CGRect pickerViewFrm = [self bounds];
    
    if (pickerViewFrm.size.width > pickerViewFrm.size.height) {
        pickerViewFrm.size.height -= (pickerViewFrm.size.height/7);
        pickerViewFrm.origin.x = (pickerViewFrm.size.width - pickerViewFrm.size.height) / 2;
        
        pickerViewFrm.size.width = pickerViewFrm.size.height;
        pickerViewFrm.origin.y = (pickerViewFrm.size.height/7)/2;
        
    }
    else {
        pickerViewFrm.size.width -= (pickerViewFrm.size.width/7);
        pickerViewFrm.origin.y = (pickerViewFrm.size.height - pickerViewFrm.size.width) / 2;
        
        pickerViewFrm.size.height = pickerViewFrm.size.width;
        pickerViewFrm.origin.x = (pickerViewFrm.size.width/7)/2;
    }

    // Declare:
    // frame
    [self.deadPiecesPickerView setFrame:pickerViewFrm];
    
    // background color
    [self.deadPiecesPickerView setBackgroundColor:[UIColor colorWithRed:(CGFloat)150/255 green:(CGFloat)150/255 blue:(CGFloat)150/255 alpha:(CGFloat)0.85]];
    
    // round corners
    self.deadPiecesPickerView.layer.cornerRadius = 15;
    self.deadPiecesPickerView.layer.masksToBounds = false;
    
    // hide
    self.deadPiecesPickerView.alpha = 0;
    
    // shadow
    self.deadPiecesPickerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.deadPiecesPickerView.layer.shadowRadius = 7;
    self.deadPiecesPickerView.layer.shadowOpacity = 0.75;
    
    //  Add to superview
    [self addSubview:self.deadPiecesPickerView];
    
}



- (void) addPiecesToBoard {
    
    for (NSString* key in self.grid) {
        
        unichar myChar = [key characterAtIndex:1];
        NSString* muhString = [NSString stringWithCharacters:&myChar length:1];
        
        if ([muhString isEqual: @"1"]) {
            [self addSubview:[self createPiece:key]];
        }
        
        if ([muhString isEqual: @"2"]) {
            [self addSubview:[self createPiece:key]];
        }
        
        if ([muhString isEqual: @"7"]) {
            [self addSubview:[self createPiece:key]];
        }
        
        if ([muhString isEqual: @"8"]) {
            [self addSubview:[self createPiece:key]];
        }
    }
}

- (UIImageView*) createPiece: (NSString*)gridID {
    
    UIView* current = (UIView*)[self.grid objectForKey:gridID];
    
    CGRect pieceFrm = CGRectMake(0, 0, self.frame.size.width/10, self.frame.size.height/10);
    pieceFrm.origin.x = (current.frame.origin.x) + ((self.frame.size.width/8) - (self.frame.size.width/10)) / 2;
    pieceFrm.origin.y = (current.frame.origin.y) + ((self.frame.size.height/8) - (self.frame.size.height/10)) / 2;

    ((UIImageView*)self.pieces[gridID]).frame = pieceFrm;
    
    unichar myChar = [gridID characterAtIndex:1];
    NSString* muhString = [NSString stringWithCharacters:&myChar length:1];
    
    if ([muhString isEqual: @"7"] || [muhString isEqual: @"8"]) {
        ((UIImageView*)self.pieces[gridID]).userInteractionEnabled = true;
    }
    else {
        ((UIImageView*)self.pieces[gridID]).userInteractionEnabled = false;
    }
    
    UITapGestureRecognizer* pieceTapped = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handlePieceTapped:)];
    
    [((UIImageView*)self.pieces[gridID]) addGestureRecognizer:pieceTapped];
    
    ((UIImageView*)self.pieces[gridID]).tag = ((int)gridID.intValue);
    
    return ((UIImageView*)self.pieces[gridID]);
}


@end



