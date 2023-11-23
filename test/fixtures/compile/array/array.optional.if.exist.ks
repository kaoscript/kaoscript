func pair(x?, y?) {
	return [
		x.value if ?x
		y.value if ?y
	]
}