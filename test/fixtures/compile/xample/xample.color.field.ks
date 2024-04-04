#![libstd(off)]
#![rules(ignore-misfit)]

import {
	'../_/_number.ks'
	'../_/_string.ks'
}

func setField(value: number | string, mod, round) {
	var field = value.toFloat().mod(mod).round(round)
}