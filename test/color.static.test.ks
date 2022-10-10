#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'chai' for expect
	'./fixtures/compile/color.ks'
}

describe('color.static', func() {
	it('from(255, 255, 0)', func() { # {{{
		var c = Color.from(255, 255, 0)

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('from([255, 255, 0])', func() { # {{{
		var c = Color.from([255, 255, 0])

		expect(c.red()).to.equal(255)
		expect(c.green()).to.equal(255)
		expect(c.blue()).to.equal(0)
	}) # }}}

	it('greyscale(255, 255, 0)', func() { # {{{
		var c = Color.greyscale(255, 255, 0)

		expect(c.red()).to.equal(237)
		expect(c.green()).to.equal(237)
		expect(c.blue()).to.equal(237)
	}) # }}}

	it('greyscale([255, 255, 0])', func() { # {{{
		var c = Color.greyscale([255, 255, 0])

		expect(c.red()).to.equal(237)
		expect(c.green()).to.equal(237)
		expect(c.blue()).to.equal(237)
	}) # }}}

	it('greyscale(255, 255, 0, lightness)', func() { # {{{
		var c = Color.greyscale(255, 255, 0, 'lightness')

		expect(c.red()).to.equal(85)
		expect(c.green()).to.equal(85)
		expect(c.blue()).to.equal(85)
	}) # }}}

	it('greyscale([255, 255, 0], lightness)', func() { # {{{
		var c = Color.greyscale([255, 255, 0], 'lightness')

		expect(c.red()).to.equal(85)
		expect(c.green()).to.equal(85)
		expect(c.blue()).to.equal(85)
	}) # }}}

	it('hex(255, 255, 0)', func() { # {{{
		expect(Color.hex(255, 255, 0)).to.equal('#ff0')
	}) # }}}

	it('hex([255, 255, 0])', func() { # {{{
		expect(Color.hex([255, 255, 0])).to.equal('#ff0')
	}) # }}}

	it('negative(255, 255, 0)', func() { # {{{
		var c = Color.negative(255, 255, 0)

		expect(c.red()).to.equal(0)
		expect(c.green()).to.equal(0)
		expect(c.blue()).to.equal(255)
	}) # }}}

	it('negative([255, 255, 0])', func() { # {{{
		var c = Color.negative([255, 255, 0])

		expect(c.red()).to.equal(0)
		expect(c.green()).to.equal(0)
		expect(c.blue()).to.equal(255)
	}) # }}}
})
