//
//  NSString+RPN.h
//
//  Created by Andrey Kadochnikov on 12.11.14.
//  Copyright (c) 2014 Andrey Kadochnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RPN)

/** 
 test:
 if infix expression is: (2.4+7.1)*3.1/3^2-(1.2^4.3+6^3)
 then postfix expression will be: 2.4 7.1 + 3.1 * 3 2 ^ / 1.2 4.3 ^ 6 3 ^ + -
 and evaluation result is: -214.91795550433343
 
 note:
 there is no inspections for any notation correctness for initial strings
 user is responsible for the correctness
**/

-(double)evaluateInfixNotationString;
-(double)evaluatePostfixNotationString;
-(NSString *)infixToPostfixWithOutputDecimalSeparator:(NSString*)separator;
-(NSArray *)infixToPostfixComponentsWithOutputDecimalSeparator:(NSString*)separator;
@end
