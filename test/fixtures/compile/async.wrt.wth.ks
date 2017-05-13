func foo(bar, qux) async {
	if qux == 0 {
		throw new Error('baaaad!')
	}
	else {
		return `\(qux)-\(bar)`
	}
}