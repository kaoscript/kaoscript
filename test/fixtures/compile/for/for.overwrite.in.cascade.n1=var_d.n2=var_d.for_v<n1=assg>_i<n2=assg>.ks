func foobar(values: Array) {
	var dyn value, i
	var dyn x = -1

	for value, i in values {
		#[overwrite] var dyn x = i

		for value, i in value.values {
			#[overwrite] var dyn x = i

			for value, i in value.values {
				#[overwrite] var dyn x = i

				for value, i in value.values {
					#[overwrite] var dyn x = i
				}
			}
		}
	}

	for value, i in values {
		#[overwrite] var dyn x = i * value.max
	}
}