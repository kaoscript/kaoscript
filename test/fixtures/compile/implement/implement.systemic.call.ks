impl Dictionary {
	static {
		length(dict: Dictionary): Number => Dictionary.keys(dict).length
	}
}

func length(data) => Dictionary.length(data)