#![target(ecma-v5)]

extern console

let values = [[[[42]]]]

if let values = values[0] {
	console.log(values)

	if let values = values[0] {
		console.log(values)

		if let values = values[0] {
			console.log(values)

			if let values = values[0] {
				console.log(values)
			}
		}
	}
}