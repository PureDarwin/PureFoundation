//
//  SwiftStubs.m
//  Foundation
//
//  Created by Stuart Crook on 26/05/2018.
//

#define SWIFTSTUB   printf("called unimplemented swift stub: %s\n", __func__);

// These are symbols which the swift runtime expects to find in Foundation, but which we have yet to implement
// In some (most) cases we don't even understand what these functions should do

void NSDataDeallocatorFree(void) {
    
    SWIFTSTUB
}

void NSDataDeallocatorUnmap(void) {
    // Data.swift #23 defines __NSDataInvokeDeallocatorUnmap() as: munmap(mem, length)
    SWIFTSTUB
}

void NSDataDeallocatorVM(void) {
    SWIFTSTUB
}


// TODO: These are listed in header files, so can / should be implemented
// NOTE: They are also implemented in Swift as part of Swift Foundation

@implementation NSAffineTransform
@end

@implementation NSDecimalNumber
@end

@implementation NSHashTable
@end

@implementation NSIndexPath
@end

@implementation NSIndexSet
@end

@implementation NSJSONSerialization
@end

@implementation NSKeyedUnarchiver
@end

@implementation NSCoder
@end

@implementation NSMutableIndexSet
@end

@implementation NSMutableURLRequest
@end

@implementation NSURLRequest
@end

@implementation NSNotification
@end

@implementation NSURLComponents
@end

@implementation NSUUID
@end





NSCalculationError NSDecimalAdd(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode) {
    SWIFTSTUB
    return NSCalculationNoError;
}

NSCalculationError NSDecimalDivide(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode) {
    SWIFTSTUB
    return NSCalculationNoError;
}

NSCalculationError NSDecimalMultiply(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode) {
    SWIFTSTUB
    return NSCalculationNoError;
}

NSCalculationError NSDecimalSubtract(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode) {
    SWIFTSTUB
    return NSCalculationNoError;
}


