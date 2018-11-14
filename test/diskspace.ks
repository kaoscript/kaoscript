#![bin]

extern {
	describe:	func
	it:			func
	console
}

import {
	'chai' for expect
	'./fixtures/compile/diskspace/diskspace.module.ks'
}

describe('diskspace', func() {
	it('print', func(done) { // {{{
		let d = await disks()

		console.log(d)

		done()
	}) // }}}
})