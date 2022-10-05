//
//  This is free and unencumbered software released into the public domain.
//  
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any
//  means.
//  
//  In jurisdictions that recognize copyright laws, the author or authors
//  of this software dedicate any and all copyright interest in the
//  software to the public domain. We make this dedication for the benefit
//  of the public at large and to the detriment of our heirs and
//  successors. We intend this dedication to be an overt act of
//  relinquishment in perpetuity of all present and future rights to this
//  software under copyright law.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa

precedencegroup LayoutConstraintPrecedence {
    associativity: left
    higherThan: TernaryPrecedence
    lowerThan: AdditionPrecedence
}

// Constraint operators
infix operator ~==~  : LayoutConstraintPrecedence  // "Equal to", activates constraint
infix operator ~==~! : LayoutConstraintPrecedence  // "Equal to", activates constraint (explicit form)
infix operator ~==~? : LayoutConstraintPrecedence  // "Equal to", no constraint activation
infix operator ~<=~  : LayoutConstraintPrecedence  // "Less than or equal to", activates constraint
infix operator ~<=~! : LayoutConstraintPrecedence  // "Less than or equal to", activates constraint (explicit form)
infix operator ~<=~? : LayoutConstraintPrecedence  // "Less than or equal to", no constraint activation
infix operator ~>=~  : LayoutConstraintPrecedence  // "Greater than or equal to", activates constraint
infix operator ~>=~! : LayoutConstraintPrecedence  // "Greater than or equal to", activates constraint (explicit form)
infix operator ~>=~? : LayoutConstraintPrecedence  // "Greater than or equal to", no constraint activation

@discardableResult
func ~==~<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return lhs ~==~! rhs
}

@discardableResult
func ~==~!<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    let constraint = lhs ~==~? rhs
    constraint.isActive = true
    return constraint
}

func ~==~?<Anchor, T>(lhsRaw: LayoutConstraintComponent<Anchor, T>, rhsRaw: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    let pair = moveTransformsToTheRight(lhs: lhsRaw, rhs: rhsRaw)

    assert(pair.rhs.multiplier == 1.0, "Multipliers are allowed only for width and height anchors")

    return pair.lhs.anchor.constraint(equalTo: pair.rhs.anchor, constant: pair.rhs.constant)
}

func ~==~?(lhsRaw: LayoutConstraintComponent<NSLayoutDimension, NSLayoutDimension>, rhsRaw: LayoutConstraintComponent<NSLayoutDimension, NSLayoutDimension>) -> NSLayoutConstraint {
    let pair = moveTransformsToTheRight(lhs: lhsRaw, rhs: rhsRaw)

    return pair.lhs.anchor.constraint(equalTo: pair.rhs.anchor, multiplier: pair.rhs.multiplier, constant: pair.rhs.constant)
}

@discardableResult
func ~<=~<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return lhs ~<=~! rhs
}

@discardableResult
func ~<=~!<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    let constraint = lhs ~<=~? rhs
    constraint.isActive = true
    return constraint
}

func ~<=~?<Anchor, T>(lhsRaw: LayoutConstraintComponent<Anchor, T>, rhsRaw: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    let pair = moveTransformsToTheRight(lhs: lhsRaw, rhs: rhsRaw)

    assert(pair.rhs.multiplier == 1.0, "Multipliers are allowed only for width and height anchors")

    return pair.lhs.anchor.constraint(lessThanOrEqualTo: pair.rhs.anchor, constant: pair.rhs.constant)
}

@discardableResult
func ~>=~<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return lhs ~>=~! rhs
}

@discardableResult
func ~>=~!<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    let constraint = lhs ~>=~? rhs
    constraint.isActive = true
    return constraint
}

func ~>=~?<Anchor, T>(lhsRaw: LayoutConstraintComponent<Anchor, T>, rhsRaw: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    let pair = moveTransformsToTheRight(lhs: lhsRaw, rhs: rhsRaw)

    return pair.lhs.anchor.constraint(greaterThanOrEqualTo: pair.rhs.anchor, constant: pair.rhs.constant)
}

// Moves all transforms to the rhs parameter
fileprivate func moveTransformsToTheRight<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: LayoutConstraintComponent<Anchor, T>) -> LayoutConstraintComponentPair<Anchor, T> {
    assert(lhs.multiplier != 0.0)

    return LayoutConstraintComponentPair(
        lhs: LayoutConstraintComponent(anchor: lhs.anchor),
        rhs: LayoutConstraintComponent(anchor: rhs.anchor,
                                 constant: rhs.constant - lhs.constant,
                                 multiplier: rhs.multiplier / lhs.multiplier))
}

struct LayoutConstraintComponent<Anchor, T> where Anchor: NSLayoutAnchor<T> {
    init(anchor: Anchor, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0) {
        self.anchor = anchor
        self.constant = constant
        self.multiplier = 1.0
    }

    let anchor: Anchor
    var constant: CGFloat = 0.0
    var multiplier: CGFloat = 1.0
}

fileprivate struct LayoutConstraintComponentPair<Anchor, T> where Anchor: NSLayoutAnchor<T> {
    let lhs: LayoutConstraintComponent<Anchor, T>
    let rhs: LayoutConstraintComponent<Anchor, T>
}

// --------------------
// Arithmetic operators
// --------------------

func +<Anchor, T>(anchor: Anchor, constant: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    return LayoutConstraintComponent(anchor: anchor, constant: constant)
}

func +<Anchor, T>(anchorAndTransforms: LayoutConstraintComponent<Anchor, T>, constant: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    var newValue = anchorAndTransforms
    newValue.constant += constant
    return newValue
}

func -<Anchor, T>(anchor: Anchor, constant: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    return LayoutConstraintComponent(anchor: anchor, constant: -constant)
}

func -<Anchor, T>(anchorAndTransforms: LayoutConstraintComponent<Anchor, T>, constant: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    return anchorAndTransforms + -constant
}

func *<Anchor, T>(anchor: Anchor, multiplier: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    assert(multiplier != 0)
    return LayoutConstraintComponent(anchor: anchor, multiplier: multiplier)
}

func *<Anchor, T>(anchorAndTransforms: LayoutConstraintComponent<Anchor, T>, multiplier: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    var newValue = anchorAndTransforms
    newValue.multiplier *= multiplier
    return newValue
}

func /<Anchor, T>(anchor: Anchor, multiplier: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    assert(multiplier != 0)
    return LayoutConstraintComponent(anchor: anchor, multiplier: 1 / multiplier)
}

func /<Anchor, T>(anchorAndTransforms: LayoutConstraintComponent<Anchor, T>, multiplier: CGFloat) -> LayoutConstraintComponent<Anchor, T> {
    assert(multiplier != 0)

    var newValue = anchorAndTransforms
    newValue.multiplier /= multiplier
    return newValue
}

// -----------------------------------------------------------------
// A bunch of operators just to support bare NSLayoutAnchor
// (not AnchorAndTransforms) on either side of constraint operators.
// -----------------------------------------------------------------

@discardableResult
func ~==~<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~==~ LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~==~<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~==~ rhs
}

@discardableResult
func ~==~<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~==~ LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~==~!<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~==~! LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~==~!<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~==~! rhs
}

@discardableResult
func ~==~!<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~==~! LayoutConstraintComponent(anchor: rhs)
}

func ~==~?<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~==~? LayoutConstraintComponent(anchor: rhs)
}

func ~==~?<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~==~? rhs
}

func ~==~?<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~==~? LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~<=~<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~<=~ LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~<=~<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~<=~ rhs
}

@discardableResult
func ~<=~<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~<=~ LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~<=~!<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~<=~! LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~<=~!<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~<=~! rhs
}

@discardableResult
func ~<=~!<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~<=~! LayoutConstraintComponent(anchor: rhs)
}

func ~<=~?<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~<=~? LayoutConstraintComponent(anchor: rhs)
}

func ~<=~?<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~<=~? rhs
}

func ~<=~?<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~<=~? LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~>=~<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~>=~ LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~>=~<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~>=~ rhs
}

@discardableResult
func ~>=~<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~>=~ LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~>=~!<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~>=~! LayoutConstraintComponent(anchor: rhs)
}

@discardableResult
func ~>=~!<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~>=~! rhs
}

@discardableResult
func ~>=~!<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~>=~! LayoutConstraintComponent(anchor: rhs)
}

func ~>=~?<Anchor, T>(lhs: Anchor, rhs: Anchor) -> NSLayoutConstraint where Anchor: NSLayoutAnchor<T> {
    return LayoutConstraintComponent(anchor: lhs) ~>=~? LayoutConstraintComponent(anchor: rhs)
}

func ~>=~?<Anchor, T>(lhs: Anchor, rhs: LayoutConstraintComponent<Anchor, T>) -> NSLayoutConstraint {
    return LayoutConstraintComponent(anchor: lhs) ~>=~? rhs
}

func ~>=~?<Anchor, T>(lhs: LayoutConstraintComponent<Anchor, T>, rhs: Anchor) -> NSLayoutConstraint {
    return lhs ~>=~? LayoutConstraintComponent(anchor: rhs)
}


