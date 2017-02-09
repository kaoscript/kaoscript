import * from ./_float.ks
import * from ./_number.ks

extern {
	console: {
		log(...args)
	}
}

func alpha(n = null, percentage = false): float {
	let i: Number = Float.parse(n)
	
	return 1 if i is NaN else (percentage ? i / 100 : i).limit(0, 1).round(3)
}