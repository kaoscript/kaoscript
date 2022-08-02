func foobar(x, y, z :String?, d: String = '') {
}

func corge(metadatas) {
	var dyn name

	for data, name of metadatas {
		foobar(data.x, data.y, null, name)
	}
}