require expect: func

func test(case, year, index) {
	var d = new Date(year, case[0], case[1])

	expect(d.getDay()).to.equal(case[index + 2])
}

var functions = []

var cases = [
	[1, 1, 6, 2]
	[6, 15, 3, 6]
	[12, 3, 0, 3]
]

for var case in cases {
	for var year, i in [1992, 2000] {
		functions.push(test^^(case, year, i))
	}
}

for var fn in functions {
	fn()
}