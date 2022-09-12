func foobar() {
	var mut x: Number? = null
	var mut y: Number? = null

	quxbaz(x ?? y ?? 42)
}

func quxbaz(x: Number) {

}