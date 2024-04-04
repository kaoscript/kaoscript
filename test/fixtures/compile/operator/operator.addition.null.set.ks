#![libstd(off)]

extern system class String

disclose String {
	length: Number
	slice(beginIndex: Number, endIndex: Number = -1): String
}

func foobar(text: String): String {
	var mut data: Array<String>? = null

	return text.slice(1 + data[0].length)
}