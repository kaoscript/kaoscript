#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'npm:chai' for expect
	'./fixtures/compile/color.ks'
}

describe('color.property', func() {
	it('alpha()', func() { # {{{
		var c = Color.new('#ff0')

		expect(c.alpha()).to.equal(1)
	}) # }}}

	it('alpha(0.5)', func() { # {{{
		var c = Color.new('#ff0').alpha(0.5)

		expect(c.hex()).to.equal('#ffff0080')
	}) # }}}

	it('red()', func() { # {{{
		var c = Color.new('#ff0')

		expect(c.red()).to.equal(255)
	}) # }}}

	it('red(128)', func() { # {{{
		var c = Color.new('#ff0').red(128)

		expect(c.hex()).to.equal('#80ff00')
	}) # }}}

	it('green()', func() { # {{{
		var c = Color.new('#ff0')

		expect(c.green()).to.equal(255)
	}) # }}}

	it('green(128)', func() { # {{{
		var c = Color.new('#ff0').green(128)

		expect(c.hex()).to.equal('#ff8000')
	}) # }}}

	it('blue()', func() { # {{{
		var c = Color.new('#ff0')

		expect(c.blue()).to.equal(0)
	}) # }}}

	it('blue(128)', func() { # {{{
		var c = Color.new('#ff0').blue(128)

		expect(c.hex()).to.equal('#ffff80')
	}) # }}}
})
