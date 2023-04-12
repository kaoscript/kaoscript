require expect: func

var functions = []

var cases = [
	[1, 1, 6, 2]
	[6, 15, 3, 6]
	[12, 3, 0, 3]
]

for var case in cases {
	for var year, i in [1992, 2000] {
		functions.push(() => {
			var d = Date.new(year, case[0], case[1])

			expect(d.getDay()).to.equal(case[i + 2])
		})
	}
}

for var fn in functions {
	fn()
}