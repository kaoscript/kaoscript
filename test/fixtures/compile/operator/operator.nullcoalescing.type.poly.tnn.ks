func foobar() {
	let x: Number? = null
	let y: Number? = null

	quxbaz(x ?? y ?? 42)
}

func quxbaz(x: Number) {

}