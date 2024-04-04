#![libstd(off)]

import './type.fusion.export.func.nrt.ks'

extern console

var match = exec()

console.log(`\(match.input)`)
console.log(`\(match[0])`)
console.log(`\(match[0]!?)`)