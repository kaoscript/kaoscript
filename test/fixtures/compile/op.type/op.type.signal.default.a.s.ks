#![libstd(off)]

import '../_/_string.ks'

func lines(value) {
	return value:!(String).lines()
}