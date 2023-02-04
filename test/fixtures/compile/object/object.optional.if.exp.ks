func pair(x?, y?) {
	return {
		x: x.value if ?x
		y: y.value if ?y
	}
}