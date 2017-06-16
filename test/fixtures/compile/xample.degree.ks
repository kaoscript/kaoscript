import './_number.ks'
import './_string.ks'

extern {
	console: {
		log(...args)
	}
}

func degree(value: number | string): number {
	return value.toInt().mod(360)
}