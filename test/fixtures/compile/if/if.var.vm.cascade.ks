extern console

var dyn values = [[[[42]]]]

if var mut values ?= values[0] {
	console.log(values)

	if var mut values ?= values[0] {
		console.log(values)

		if var mut values ?= values[0] {
			console.log(values)

			if var mut values ?= values[0] {
				console.log(values)
			}
		}
	}
}