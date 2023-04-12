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
		var c = Color.new('#ff0')

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('rgb(255, 255, 0)', func() { # {{{
		var c = Color.new('rgb(255, 255, 0)')

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('255, 255, 0', func() { # {{{
		var c = Color.new(255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('[255, 255, 0]', func() { # {{{
		var c = Color.new([255, 255, 0])

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('rgb, 255, 255, 0', func() { # {{{
		var c = Color.new('rgb', 255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('srgb, 255, 255, 0', func() { # {{{
		var c = Color.new('srgb', 255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('{r:255, g:255, b:0}', func() { # {{{
		var c = Color.new({r:255, g:255, b:0})

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('{red:255, green:255, blue:0}', func() { # {{{
		var c = Color.new({red:255, green:255, blue:0})

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('gray(128)', func() { # {{{
		var c = Color.new('gray(128)')

		expect(c.red()).to.equal(128)
		expect(c.green()).to.equal(128)
		expect(c.blue()).to.equal(128)
	}) # }}}

	it('gray, 128', func() { # {{{
		var c = Color.new('gray', 128)

		expect(c.red()).to.equal(128)
		expect(c.green()).to.equal(128)
		expect(c.blue()).to.equal(128)
	}) # }}}

	it('clone', func() { # {{{
		var c = Color.new('#ff0').clone()

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('copy', func() { # {{{
		var t = Color.new()
		var c = Color.new('#ff0')

		c.copy(t)

		expect(t.red()).to.equal(255)
		expect(t.green()).to.equal(255)
		expect(t.blue()).to.equal(0)
	}) # }}}
})
