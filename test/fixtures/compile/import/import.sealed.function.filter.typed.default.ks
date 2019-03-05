extern console

import '../_/_function.ks'
require|import './import.sealed.function.source.ks' {
	template: {
		compile(): Function
	}
}

func foo() => 42

console.log(foo.toSource())
console.log(template.compile().toSource())