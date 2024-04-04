#![libstd(off)]

import '../_/_array.last.ks'(...)

func foobar(values: String[][]) {
	for var vals in values {
		var last = vals.last()
	}
}