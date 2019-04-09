#![target(ecma-v5)]

func foobar(values: Array) {
	const x = -1

	for const value, i in values {
		const x = i

		for const value, i in value.values {
			const x = i

			for const value, i in value.values {
				const x = i

				for const value, i in value.values {
					const x = i
				}
			}
		}
	}

	for const value, i in values {
		const x = i * value.max
	}
}