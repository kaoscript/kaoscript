type Data = Object & { type: Number }

func foobar(data: Data): Number {
	return data.type
}