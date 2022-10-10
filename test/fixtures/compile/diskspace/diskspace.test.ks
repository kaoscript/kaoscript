#![bin]

extern {
	func describe(title: String, fn: (): Void): Void
	func it(title: string, fn: (#[retain] done: Function): Void): Void

	console
}

import {
	'chai' for expect
	'./diskspace.module.ks'
}

describe('diskspace', func() {
	it('print', func(done) { # {{{
		var d = await disks()

		expect(d).to.have.length.above(0)

		console.log(d)

		done()
	}) # }}}
})