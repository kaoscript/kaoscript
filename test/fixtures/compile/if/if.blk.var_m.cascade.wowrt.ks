extern console

var mut values = [[[[42]]]]

if #[overwrite] var mut values ?= values[0] {
	console.log(values)

	if #[overwrite] var mut values ?= values[0] {
		console.log(values)

		if #[overwrite] var mut values ?= values[0] {
			console.log(values)

			if #[overwrite] var mut values ?= values[0] {
				console.log(values)
			}
		}
	}
}