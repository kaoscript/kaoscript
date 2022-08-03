import {
	'../_/_string.ks'
}

var $formatters = {}

func format(mut format: String) {
	if format ?= $formatters[format] {
		return format.formatter(format.space)
	}
	else {
		return false
	}
}