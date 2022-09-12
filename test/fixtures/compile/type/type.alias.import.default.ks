import '../_/_number.ks'
import '../_/_string.ks'
import './type.alias.export.decl.ks'

extern console: {
	log(...args)
}

var mut n: T = 0

console.log(n.toInt())

var mut s: T = ''

console.log(s.toInt())

func foobar(x: T) {
	console.log(x.toInt())
}

n = ''

console.log(n.toInt())

n = 42

console.log(n.toInt())

func qux(): T => 42

n = qux()

console.log(n.toInt())