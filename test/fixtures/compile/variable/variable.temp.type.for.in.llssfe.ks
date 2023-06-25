import '../_/_array.last.ks'(...)

func foobar(values: Array<String[]>) {
	for var vals in values {
		var last = vals.last()
	}
}