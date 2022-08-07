extern {
	func it(...)
}

it('print', func(#[preserve] done) {
	done()
})