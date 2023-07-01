#![bin]

extern {
	describe:	func
	it:			func
	console
}

import {
	'npm:chai' for expect
	'./fixtures/compile/diskspace/diskspace.module.ks'
}

describe('diskspace', func() {
	it('print', func(#[retain] done) { # {{{
		var d = await disks()

		console.log(d)

		done()
	}) # }}}
})
