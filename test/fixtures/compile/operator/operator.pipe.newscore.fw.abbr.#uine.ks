extern {
	func getScoreOrNull(person): Number?
	func double(x: Number): Number
	func add(x: Number, y: Number): Number
	func boundScore(min: Number, max: Number, x: Number): Number
}

func getSupervisorName(person): Number? {
	var newScore = person
		|>  getScoreOrNull
		|>? double
		|>  add(7, _)
		|>  boundScore(0, 100, _)

	return newScore
}