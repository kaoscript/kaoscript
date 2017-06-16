import './_float.ks'
import './_number.ks'

extern {
	console: {
		log(...args): void
	}
}

func hex(n: string | number): Number { // {{{
	return Float.parse(n).limit(0, 255).round()
} // }}}

console.log(hex(128))