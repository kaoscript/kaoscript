import '../_/_float.ks'
import '../_/_number.ks'

extern {
	console: {
		log(...args)
	}
}

func alpha(n? = null, percentage = false): Number {
	var dyn i: Number = Float.parse(n)

	return 1 if i == NaN else (percentage ? i / 100 : i).limit(0, 1).round(3)
}