func foobar() {
	var dyn x: Number? = null
	var dyn y: Number? = null

	quxbaz(x ?? y ?? 42)
}

func quxbaz(x: Number) {

}