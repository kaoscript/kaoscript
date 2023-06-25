extern console

import './tuple.export.named.ks'

var pair = Pair.new('x', 0.1)

console.log(`\(pair.x)`, pair.y + 1)

export Pair