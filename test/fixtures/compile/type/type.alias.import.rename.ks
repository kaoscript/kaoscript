import '../_/_number.ks'
import '../_/_string.ks'
import './type.alias.export.decl.ks' for T => NS

extern console: {
	log(...args)
}

let n: NS = 0

console.log(n.toInt())

let s: NS = ''

console.log(s.toInt())

func foobar(x: NS) {
	console.log(x.toInt())
}

n = ''

console.log(n.toInt())

n = 42

console.log(n.toInt())

func qux(): NS => 42

n = qux()

console.log(n.toInt())