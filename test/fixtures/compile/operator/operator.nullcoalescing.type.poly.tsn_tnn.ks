func foobar() {
	var dyn x: String? = null
	var dyn y: Number? = null

	quxbaz(x ?? y ?? 42)
}

func quxbaz(x: Number) {

}