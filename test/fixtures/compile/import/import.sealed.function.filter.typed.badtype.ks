extern console

import '../_/_function.ks'
require|import './import.sealed.function.source.ks' {
	template: {
		render(...): String
	}
}

func foo() => 42

console.log(foo.toSource())
console.log(template.compile().toSource())