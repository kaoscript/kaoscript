var dyn foo = (() => [1, 2])()
var dyn bar = []

bar.push(...foo)