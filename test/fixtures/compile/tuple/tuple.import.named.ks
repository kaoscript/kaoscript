extern console

import './tuple.export.named'

const pair = Pair('x', 0.1)

console.log(`\(pair.x)`, pair.y + 1)

export Pair