var dyn foo = (() => [1, 2])()
var dyn bar = []

bar.push(0, 4, ...foo)