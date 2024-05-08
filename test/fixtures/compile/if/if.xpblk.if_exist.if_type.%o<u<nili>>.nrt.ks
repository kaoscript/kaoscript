func foobar(values: Number[] | Number | Null) {
	return {
		values: (
			if values is Array {
				set values
			}
			else {
				set values
			}
		) if ?values
	}
}