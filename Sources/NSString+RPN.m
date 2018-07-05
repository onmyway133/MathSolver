//
//  NSString+RPN.m
//
//  Created by Andrey Kadochnikov on 12.11.14.
//  Copyright (c) 2014 Andrey Kadochnikov. All rights reserved.
//

#import "NSString+RPN.h"
#import <math.h>

@implementation NSString (RPN)

-(double)evaluatePostfixNotationString
{
    NSArray * postfixComponents = [self componentsSeparatedByString:@" "];
    NSString * numbers = @"0123456789";
    NSString * operators = @"^*/-+";
    
    NSCharacterSet * numbersSet = [NSCharacterSet characterSetWithCharactersInString: numbers];
    NSCharacterSet * operatorsSet = [NSCharacterSet characterSetWithCharactersInString: operators];
    
    NSMutableArray * stack = [NSMutableArray array];
    for (NSInteger compIdx=0; compIdx < postfixComponents.count; compIdx++)
    {
        @autoreleasepool {
            
            NSString * charStr = postfixComponents[compIdx];
            unichar firstCharForComponent = [charStr characterAtIndex:0];
            
            if ([numbersSet characterIsMember:firstCharForComponent]){
                // number
                [stack addObject: charStr];
                
            } else if ([operatorsSet characterIsMember:firstCharForComponent]) {
                // operator
                NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( stack.count - 2, 2)];
                
                NSArray * operands;
                if (stack.count >= 2){
                    operands = [stack objectsAtIndexes: indexSet];
                } else {
                    continue;
                }
                double result = [self applyOperator:charStr toOperands:operands];
                [stack removeObjectsAtIndexes:indexSet];
                [stack addObject: [NSString stringWithFormat:@"%f", result]];
            }
        }
    }
    double result = [[stack firstObject] doubleValue];
    return result;
}

-(double)evaluateInfixNotationString
{
    NSString * postfix = [self infixToPostfixWithOutputDecimalSeparator:@"."];
    return [postfix evaluatePostfixNotationString];
}

-(NSString *)infixToPostfixWithOutputDecimalSeparator:(NSString*)separator
{
    NSArray * components = [self infixToPostfixComponentsWithOutputDecimalSeparator:separator];
    return  [components componentsJoinedByString:@" "];
}

-(NSArray *)infixToPostfixComponentsWithOutputDecimalSeparator:(NSString*)separator
{
//TODO: no unbalanced brackets errors handling
    NSString * outputDecSeparatorString = separator?:@".";
    unichar outDecSeparatorChar = [outputDecSeparatorString characterAtIndex:0];
    
    NSCharacterSet * possibleSeparatorsSet = [NSCharacterSet characterSetWithCharactersInString: @",."];
    NSRange firstAccuredSeparatorRange = [self rangeOfCharacterFromSet:possibleSeparatorsSet];
    unichar usedDecSeparatorChar;
    if (firstAccuredSeparatorRange.location == NSNotFound){
        usedDecSeparatorChar = '.';
    } else {
        usedDecSeparatorChar = [self characterAtIndex:firstAccuredSeparatorRange.location];
    }
    
    NSDictionary * priorities = @{@"^" : @(3),
                                  @"*" : @(2),
                                  @"/" : @(2),
                                  @"-" : @(1),
                                  @"+" : @(1),
                                  };
    NSString * operatorsString = [priorities.allKeys componentsJoinedByString:@""];
    NSCharacterSet * numbersSet = [NSCharacterSet characterSetWithCharactersInString: @"0123456789"];
    NSCharacterSet * operatorsSet = [NSCharacterSet characterSetWithCharactersInString: operatorsString ];
    NSCharacterSet * bracketsSet = [NSCharacterSet characterSetWithCharactersInString: @"()"];
    
    NSMutableCharacterSet * allowedCharSet = [[NSMutableCharacterSet alloc] init];
    [allowedCharSet formUnionWithCharacterSet:numbersSet];
    [allowedCharSet formUnionWithCharacterSet:operatorsSet];
    [allowedCharSet formUnionWithCharacterSet:bracketsSet];
    [allowedCharSet addCharactersInRange:NSMakeRange(usedDecSeparatorChar, 1)];
    NSCharacterSet * forbiddenCharSet = [allowedCharSet invertedSet];
    allowedCharSet = nil;
    
    NSString * originalString = self.copy;
    NSString * cleanString = [[originalString componentsSeparatedByCharactersInSet:forbiddenCharSet] componentsJoinedByString:@""];
    forbiddenCharSet = nil;
    originalString = nil;
    
    __block NSMutableArray * output = [NSMutableArray array];
    NSMutableArray * operatorStack = [NSMutableArray array];
    
    for (NSInteger charIdx=0; charIdx < cleanString.length; charIdx++)
    {
        @autoreleasepool {
            unichar achar = [cleanString characterAtIndex:charIdx];
            NSString * stringChar = [NSString stringWithCharacters:&achar length:1];
            
            if (achar == usedDecSeparatorChar){
                // separator
                NSString * topCharStr = output.lastObject;
                NSString * numberWithSeparator = [topCharStr stringByAppendingString: outputDecSeparatorString];
                [output replaceObjectAtIndex: output.count-1 withObject: numberWithSeparator];
                
            } else if ([numbersSet characterIsMember:achar]){
                // number
                NSInteger next = charIdx;
                unichar nextDigit = achar;
                NSMutableString * number = [NSMutableString string];
                while (next < cleanString.length)
                {
                    nextDigit = [cleanString characterAtIndex:next];
                    if ((nextDigit == usedDecSeparatorChar || [numbersSet characterIsMember:nextDigit])){
                        
                        if (nextDigit == usedDecSeparatorChar){// заменяем разделитель
                            nextDigit = outDecSeparatorChar;
                        }
                        
                        [number appendString:[NSString stringWithCharacters:&nextDigit length:1]];
                    } else {
                        break;
                    }
                    next ++;
                }
                
                [output addObject: number ];
                charIdx = next-1;
                
            } else if ([operatorsSet characterIsMember:achar]) {
                // operator
                NSInteger currentOperatorPriority = [priorities[stringChar] integerValue];
                
                [operatorStack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSInteger topOperatorPriority = [priorities [[operatorStack lastObject]] integerValue];
                    if (currentOperatorPriority <= topOperatorPriority){
                        [output addObject: [operatorStack lastObject]];
                        [operatorStack removeLastObject];
                    }
                }];
                [operatorStack addObject:stringChar];
                
            } else if ([bracketsSet characterIsMember:achar]) {
                // brackets
                if (achar == '('){
                    [operatorStack addObject: [NSString stringWithCharacters:&achar length:1]];
                } else {
                    [operatorStack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * str, NSUInteger idx, BOOL *stop) {
                        if (achar == '('){
                            [operatorStack removeLastObject];
                            *stop = YES;
                        } else {
                            unichar lastOperatorChar = [(NSString*)[operatorStack lastObject] characterAtIndex:0];
                            if ([operatorsSet characterIsMember: lastOperatorChar]){
                                NSString * lastOperatorString = [NSString stringWithCharacters:&lastOperatorChar length:1];
                                [output addObject: lastOperatorString];
                            }
                            [operatorStack removeLastObject];
                        }
                    }];
                }
            }
        } //autoreleasepool
    };
    // reverse array
    if (operatorStack.count){
        NSUInteger i = 0;
        NSUInteger j = operatorStack.count - 1;
        while (i < j) {
            [operatorStack exchangeObjectAtIndex:i withObjectAtIndex:j];
            i++;
            j--;
        }
    }
    // build output
    [output addObjectsFromArray: operatorStack];
    return output;
}

-(double)applyOperator:(NSString *)operator toOperands:(NSArray *)operands
{
    void(^calculationBlock)(NSString * operand, NSUInteger idx, BOOL *stop) ;
    __block double result = 0;
    
    if ([operator isEqualToString:@"^"]){
        calculationBlock = ^(NSString * operand, NSUInteger idx, BOOL *stop) {
            if (idx == 0){
                result = operand.doubleValue;
            } else {
                result = pow(result, operand.doubleValue);;
            }
        };
    }
    
    if ([operator isEqualToString:@"/"]){
        calculationBlock = ^(NSString * operand, NSUInteger idx, BOOL *stop) {
            if (idx == 0){
                result = operand.doubleValue;
            } else {
                result /= operand.doubleValue;
            }
        };
    }
    if ([operator isEqualToString:@"-"]){
        calculationBlock = ^(NSString * operand, NSUInteger idx, BOOL *stop) {
            if (idx == 0){
                result = operand.doubleValue;
            } else {
                result -= operand.doubleValue;
            }
        };
    }
    if ([operator isEqualToString:@"*"]){
        calculationBlock = ^(NSString * operand, NSUInteger idx, BOOL *stop) {
            if (idx == 0){
                result = operand.doubleValue;
            } else {
                result *= operand.doubleValue;
            }
        };
    }
    if ([operator isEqualToString:@"+"]){
        calculationBlock = ^(NSString * operand, NSUInteger idx, BOOL *stop) {
            result += operand.doubleValue;
        };
    }
    
    [operands enumerateObjectsUsingBlock: calculationBlock];
    return result;
}
@end
