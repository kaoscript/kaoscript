import '../_/_number.ks'

extern {
	console: {
		log(...args): void
	}
	Float: {
		parse(value): Number
	}
}

func hex(n: string | number): Number { // {{{
	return Float.parse(n).limit(0, 255).round()
} // }}}

console.log(hex(128))