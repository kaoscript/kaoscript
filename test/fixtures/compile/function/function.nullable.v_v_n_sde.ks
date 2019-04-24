func foobar(x, y, z :String?, d: String = '') {
}

func corge(metadatas) {
	let name

	for name, data of metadatas {
		foobar(data.x, data.y, null, name)
	}
}