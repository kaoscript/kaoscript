import {
	'../_/_string.ks'
}

const $formatters = {}

func format(format: String) {
	if const format = $formatters[format] {
		return format.formatter(format.space)
	}
	else {
		return false
	}
}