func getNewScore(person: { score: Number }): Number {
	var newScore = person.score
		|> (score) => double(score)
		|> (score) => add(7, score)
		|> (score) => boundScore(0, 100, score)

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
