func foobar(values: Array) {
	let x = -1

	for value, i in values {
		let x = i

		for value, i in value.values {
			let x = i

			for value, i in value.values {
				let x = i

				for value, i in value.values {
					let x = i
				}
			}
		}
	}

	for value, i in values {
		let x = i * value.max
	}
}