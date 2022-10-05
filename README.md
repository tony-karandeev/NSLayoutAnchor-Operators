# NSLayoutAnchor-Operators

This tiny Swift library defines a set of operators that make constraint definitions much more readable. For example:

```swift
// Classic way
view.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor,
                                   multiplier: 1.0,
                                     constant: -50).isActive = true

// Concise way
view.widthAnchor ~<=~ container.widthAnchor - 50
```

Notice that there's no `isActive = true` in the second statement. That's because the constraint is activated immediately by default. Constraint requires additional setup before activation? Just append `?` to the operator and activate the resulting constraint manually when needed:

```swift
let constraint = view.widthAnchor ~==~? container.widthAnchor
constraint.priority = NSLayoutPriorityDefaultLow + 1
constraint.isActive = true
```

There are three types of constraint operators, and each has variations related to constraint activation behavior:
```
~==~   -  "Equal to", activates constraint
~==~!  -  "Equal to", activates constraint (explicit form)
~==~?  -  "Equal to", no constraint activation
~<=~   -  "Less than or equal to", activates constraint
~<=~!  -  "Less than or equal to", activates constraint (explicit form)
~<=~?  -  "Less than or equal to", no constraint activation
~>=~   -  "Greater than or equal to", activates constraint
~>=~!  -  "Greater than or equal to", activates constraint (explicit form)
~>=~?  -  "Greater than or equal to", no constraint activation
```


As you may've inferred from the first example, multiplier and constraint can be written down as trivial arithmetic operations. What the first example doesn't show is that these values can appear on both sides of a constraint operator:

```swift
label.bottomAnchor + 12 ~==~ button.topAnchor
label.widthAnchor * 2 ~==~ contentView.widthAnchor - 30
```
