func foobar(values: Array) {
	var x = -1

	for var value, i in values {
		var x = i

		for var value, i in value.values {
			var x = i

			for var value, i in value.values {
				var x = i

				for var value, i in value.values {
					var x = i
				}
			}
		}
	}

	for var value, i in values {
		var x = i * value.max
	}
}