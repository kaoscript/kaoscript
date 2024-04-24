func foobar(x, y, z :String?, d: String = '') {
}

func corge(metadatas) {
	for var data, name of metadatas {
		foobar(data.x, data.y, null, name)
	}
}