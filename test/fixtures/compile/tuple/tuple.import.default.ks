extern console

import './tuple.export.default'

var pair = Pair.new('x', 0.1)

console.log(`\(pair.0)`, pair.1 + 1)

export Pair