import * from ./_float.ks
import * from ./_number.ks

extern {
	console: {
		log(...args) -> void
	}
}

func hex(n: string | number) -> int { // {{{
	return Float.parse(n).limit(0, 255).round()
} // }}}

console.log(hex(128))