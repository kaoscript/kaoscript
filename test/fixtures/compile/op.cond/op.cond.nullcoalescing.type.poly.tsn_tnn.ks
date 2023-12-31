func foobar() {
	var mut x: String? = null
	var mut y: Number? = null

	quxbaz(x ?? y ?? 42)
}

func quxbaz(x: Number) {

}