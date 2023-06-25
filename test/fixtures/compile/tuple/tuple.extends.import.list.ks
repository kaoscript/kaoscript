extern console

import './tuple.extends.list.ks'

var triple = Triple.new('x', 0.1, true)

console.log(`\(triple.0)`, triple.1 + 1, !triple.2)