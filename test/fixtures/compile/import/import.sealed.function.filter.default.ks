extern console

import '../_/_function.ks'
require|import './import.sealed.function.source.ks' for template

func foo() => 42

console.log(foo.toSource())
console.log(template.compile().toSource())

export template