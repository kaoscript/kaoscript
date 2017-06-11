import * from './_number.ks'

extern {
	console: {
		log(...args)
	}
	Float: {
		parse(value): Number
	}
}

let $caster = {
	hex(n: string | number): Number { // {{{
		return Float.parse(n).limit(0, 255).round()
	} // }}}
}

console.log($caster.hex(128))