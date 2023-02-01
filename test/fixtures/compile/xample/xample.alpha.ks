import '../_/_float.ks'
import '../_/_number.ks'

extern {
	console: {
		log(...args)
	}
}

func alpha(n? = null, percentage = false): Number {
	var mut i: Number = Float.parse(n)

	return i == NaN ? 1 : (percentage ? i / 100 : i).limit(0, 1).round(3)
}