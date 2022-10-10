#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'chai' for expect
	'./fixtures/compile/color.ks'
}

describe('color.create', func() {
	it('#ff0', func() { # {{{
		var c = new Color('#ff0')

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('rgb(255, 255, 0)', func() { # {{{
		var c = new Color('rgb(255, 255, 0)')

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('255, 255, 0', func() { # {{{
		var c = new Color(255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('[255, 255, 0]', func() { # {{{
		var c = new Color([255, 255, 0])

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('rgb, 255, 255, 0', func() { # {{{
		var c = new Color('rgb', 255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('srgb, 255, 255, 0', func() { # {{{
		var c = new Color('srgb', 255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('{r:255, g:255, b:0}', func() { # {{{
		var c = new Color({r:255, g:255, b:0})

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('{red:255, green:255, blue:0}', func() { # {{{
		var c = new Color({red:255, green:255, blue:0})

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('gray(128)', func() { # {{{
		var c = new Color('gray(128)')

		expect(c.red()).to.equal(128)
		expect(c.green()).to.equal(128)
		expect(c.blue()).to.equal(128)
	}) # }}}

	it('gray, 128', func() { # {{{
		var c = new Color('gray', 128)

		expect(c.red()).to.equal(128)
		expect(c.green()).to.equal(128)
		expect(c.blue()).to.equal(128)
	}) # }}}

	it('clone', func() { # {{{
		var c = new Color('#ff0').clone()

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('copy', func() { # {{{
		var t = new Color()
		var c = new Color('#ff0')

		c.copy(t)

		expect(t.red()).to.equal(255)
		expect(t.green()).to.equal(255)
		expect(t.blue()).to.equal(0)
	}) # }}}
})
