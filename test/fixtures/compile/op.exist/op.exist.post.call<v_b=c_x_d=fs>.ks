#![libstd(off)]

import '../_/_string.ks'

func foobar(values: Array<String>) {
	return values[0]?.toInt()
}