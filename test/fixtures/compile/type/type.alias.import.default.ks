import '../_/_number.ks'
import '../_/_string.ks'
import './type.alias.export.decl.ks'

extern console: {
	log(...args)
}

let x: T = 0

console.log(x.toInt())