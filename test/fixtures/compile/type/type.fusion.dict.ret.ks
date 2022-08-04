type Data = Dictionary & { type: Number }

func foobar(data: Data): Number {
	return data.type
}