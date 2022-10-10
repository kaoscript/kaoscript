#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'chai' for expect
	'./fixtures/compile/color.ks'
}

describe('color.format', func() {
	describe('hex', func() {
		it('hex', func() { # {{{
			expect(new Color('#ff0').format('hex')).to.equal('#ff0')
		}) # }}}

		it('rgb', func() { # {{{
			expect(new Color('#ff0').format('rgb')).to.equal('rgb(255, 255, 0)')
		}) # }}}

		it('hex with alpha', func() { # {{{
			expect(new Color('#ff0d').format('hex')).to.equal('#ff0d')
		}) # }}}

		it('rgb with alpha', func() { # {{{
			expect(new Color('#ff0d').format('rgb')).to.equal('rgba(255, 255, 0, 0.867)')
		}) # }}}
	})
})
