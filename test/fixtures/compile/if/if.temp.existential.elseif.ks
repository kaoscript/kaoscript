extern console

func parse(color: Object | String) {
	if color is String {
		if match ?= /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color) {
			console.log(match)
		}
		else if match ?= /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color) {
			console.log(match)
		}
	}
}