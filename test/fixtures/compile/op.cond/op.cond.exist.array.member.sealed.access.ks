#![libstd(off)]

extern console

import '../_/_string.ks'

func foobar(values: Array<String>) {
	return values[0]?.toInt
}