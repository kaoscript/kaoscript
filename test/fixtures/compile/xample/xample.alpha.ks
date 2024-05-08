import '../_/_float.ks'
import '../_/_number.ks'

extern {
	console: {
		log(...args)
	}
}

func alpha(n? = null, percentage = false): Number {
	var mut i: Number = Float.parse(n)

	return if i == NaN set 1 else (if percentage set i / 100 else i).limit(0, 1).round(3)
}