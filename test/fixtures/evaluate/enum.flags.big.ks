require expect: func

flagged enum Foobar {
	e00
	e01
	e02
	e03
	e04
	e05
	e06
	e07
	e08
	e09
	e10
	e11
	e12
	e13
	e14
	e15
	e16
	e17
	e18
	e19
	e20
	e21
	e22
	e23
	e24
	e25
	e26
	e27
	e28
	e29
	e30
	e31
	e32
	e33
	e34
	e35
	e36
	e37
	e38
	e39
	e40
	e41
	e42
	e43
	e44
	e45
	e46
	e47
	e48
	e49
}

func contains(e1: Foobar, e2: Foobar) {
	return e1 ~~ e2
}

expect(contains(Foobar::e42 + Foobar::e08, Foobar::e42)).to.equal(true)
expect(contains(Foobar::e42 + Foobar::e08, Foobar::e08)).to.equal(true)
expect(contains(Foobar::e42 + Foobar::e08, Foobar::e10)).to.equal(false)