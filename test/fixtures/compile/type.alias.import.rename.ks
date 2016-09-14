import * from ./_number.ks
import * from ./_string.ks
import T as NS from ./type.alias.export.decl.ks

extern console: {
	log(...args)
}

let x: NS = 0

console.log(x.toInt())