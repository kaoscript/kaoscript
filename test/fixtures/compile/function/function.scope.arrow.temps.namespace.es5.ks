#![target(ecma-v5)]

require expect: func

namespace Test {
	const functions = []

	const cases = [
		[1, 1, 6, 2]
		[6, 15, 3, 6]
		[12, 3, 0, 3]
	]

	for const fn in functions {
		for const case in cases {
			for const year, i in [1992, 2000] {
				fn()
			}
		}
	}

	for const case in cases {
		for const year, i in [1992, 2000] {
			functions.push(() => {
				const d = new Date(year, case[0], case[1])

				expect(d.getDay()).to.equal(case[i + 2])

				(() => {
					const d = new Date(year, case[0], case[1])

					expect(d.getDay()).to.equal(case[i + 2])
				})()
			})
		}
	}

	for const fn in functions {
		for const case in cases {
			for const year, i in [1992, 2000] {
				fn()
			}
		}
	}
}