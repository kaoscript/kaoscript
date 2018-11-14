import '../_/_number.ks'
import '../_/_string.ks'

extern console: {
	log(...args)
}

type T = number | string

let x: T = 0

console.log(x.toInt())