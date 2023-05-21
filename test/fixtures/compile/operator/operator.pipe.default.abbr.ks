func getNewScore(person: { score: Number }): Number {
	var newScore = person.score
		|> double
		|> add(7, _)
		|> boundScore(0, 100, _)

	return newScore
}

func add(x: Number, y: Number): Number {
	return x + y
}

func boundScore(min: Number, max: Number, x: Number): Number {
	if x < min {
		return min
	}
	else if x > max {
		return max
	}
	else {
		return x
	}
}

func double(x: Number): Number {
	return x * 2
}
