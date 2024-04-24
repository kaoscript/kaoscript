#![libstd(off)]

import {
	'../_/_string.ks'
}

var $formatters = {}

func format(name: String) {
	if var { formatter, space } ?= $formatters[name] {
		return formatter(space)
	}
	else {
		return false
	}
}