type Data = Object & { type: Number }

func foobar(data: Data) {
	return data.x
}