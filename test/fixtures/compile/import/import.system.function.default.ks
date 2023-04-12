extern console

import '../_/_function.ks'
import './import.system.function.source.ks'

func foo() => 42

console.log(foo.toSource())
console.log(template.compile().toSource())
console.log(Template.new().compile().toSource())