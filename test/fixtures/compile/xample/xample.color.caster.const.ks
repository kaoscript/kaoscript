import {
	'../_/_float.ks'
	'../_/_math.ks'
	'../_/_number.ks'
}

type float = Number

namespace $caster {
	export func percentage(n): float {
		return Float.parse(n).limit(0, 100).round(1)
	}
}

func srgb(that, color): bool {
	if var match ?= /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color) {
		that._red = Math.round(2.55 * $caster.percentage(match[1]))
		that._green = Math.round(2.55 * $caster.percentage(match[2]))
		that._blue = Math.round(2.55 * $caster.percentage(match[3]))

		return true
	}
	else {
		return false
	}
}