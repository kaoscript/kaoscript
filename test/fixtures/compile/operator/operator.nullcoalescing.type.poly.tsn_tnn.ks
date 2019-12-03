func foobar() {
	let x: String? = null
	let y: Number? = null

	quxbaz(x ?? y ?? 42)
}

func quxbaz(x: Number) {

}