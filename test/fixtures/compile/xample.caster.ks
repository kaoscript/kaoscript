import * from ./_number.ks

extern {
	console: {
		log(...args)
	}
	Float: {
		parse(value): Number
	}
}

let $caster = {
	hex(n: string | number): int { // {{{
		return Float.parse(n).limit(0, 255).round()
	} // }}}
}

console.log($caster.hex(128))