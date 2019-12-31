extern console

import '../_/_function.ks'
require|import './import.systemic.function.source.ks' {
	template: {
		render(...): String
	}
}

func foo() => 42

console.log(foo.toSource())
console.log(template.compile().toSource())