var dyn foo = (() => [1, 2])()
var dyn bar = []
var dyn qux = (() => [3, 2])()

bar.push(0, 4, ...foo, 1, ...qux, 7, 9)