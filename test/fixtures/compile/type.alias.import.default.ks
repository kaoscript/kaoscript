import * from './_number.ks'
import * from './_string.ks'
import * from './type.alias.export.decl.ks'

extern console: {
	log(...args)
}

let x: T = 0

console.log(x.toInt())