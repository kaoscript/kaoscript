#![retain-parameters]

extern {
	func it(...)
}

it('print', func(done) {
	done()
})