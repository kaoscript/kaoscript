import './_number.ks'
import './_string.ks'
import './type.alias.export.decl.ks' for T => NS

extern console: {
	log(...args)
}

let x: NS = 0

console.log(x.toInt())