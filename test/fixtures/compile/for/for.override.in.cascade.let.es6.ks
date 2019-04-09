func foobar(values: Array) {
	let x = -1

	for let value, i in values {
		let x = i

		for let value, i in value.values {
			let x = i

			for let value, i in value.values {
				let x = i

				for let value, i in value.values {
					let x = i
				}
			}
		}
	}

	for let value, i in values {
		let x = i * value.max
	}
}