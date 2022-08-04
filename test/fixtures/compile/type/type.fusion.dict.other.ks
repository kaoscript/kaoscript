type Data = Dictionary & { type: Number }

func foobar(data: Data) {
	return data.x
}