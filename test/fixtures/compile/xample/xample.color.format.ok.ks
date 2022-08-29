import {
	'../_/_string.ks'
}

var $formatters = {}

func format(format: String) {
	if var format ?= $formatters[format] {
		return format.formatter(format.space)
	}
	else {
		return false
	}
}