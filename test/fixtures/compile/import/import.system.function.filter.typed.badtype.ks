extern console

import '../_/_function.ks'
require|import './import.system.function.source.ks' for {
	type template = {
		render(...): String
	}
}

func foo() => 42

console.log(foo.toSource())
console.log(template.compile().toSource())