var foo: array = (() => [1, 2])()
var bar = []

bar.push(...foo)