func foobar(values: Array) {
	var x = -1

	for #[overwrite] var value, i in values {
		#[overwrite] var x = i

		for #[overwrite] var value, i in value.values {
			#[overwrite] var x = i

			for #[overwrite] var value, i in value.values {
				#[overwrite] var x = i

				for #[overwrite] var value, i in value.values {
					#[overwrite] var x = i
				}
			}
		}
	}

	for var value, i in values {
		#[overwrite] var x = i * value.max
	}
}