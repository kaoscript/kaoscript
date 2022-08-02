import '../_/_number.ks'

extern {
	console: {
		log(...args)
	}
	Float: {
		parse(value): Number
	}
}

var dyn $caster = {
	hex(n: string | number): Number { // {{{
		return Float.parse(n).limit(0, 255).round()
	} // }}}
}

console.log($caster.hex(128))