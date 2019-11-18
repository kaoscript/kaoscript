extern console

import './struct.array.export.named'

const pair = new Pair('x', 0.1)

console.log(`\(pair.x)`, pair.y + 1)

export Pair