impl Object {
	static {
		length(dict: Object): Number => Object.keys(dict).length
	}
}

func length(data) => Object.length(data)