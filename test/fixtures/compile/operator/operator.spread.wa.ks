var dyn foo: array = (() => [1, 2])()
var dyn bar = []

bar.push(...foo)