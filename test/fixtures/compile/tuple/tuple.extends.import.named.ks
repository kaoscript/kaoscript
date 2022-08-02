extern console

import './tuple.extends.named'

var triple = Triple('x', 0.1, true)

console.log(`\(triple.x)`, triple.y + 1, !triple.z)