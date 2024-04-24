func foobar(values: Array) {
	var dyn x = -1

	for var value, i in values {
		#[overwrite] var dyn x = i

		for var value, i in value.values {
			#[overwrite] var dyn x = i

			for var value, i in value.values {
				#[overwrite] var dyn x = i

				for var value, i in value.values {
					#[overwrite] var dyn x = i
				}
			}
		}
	}

	for var value, i in values {
		#[overwrite] var dyn x = i * value.max
	}
}