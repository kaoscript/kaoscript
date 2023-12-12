type Result = {
	values: Number[] | Number | Null
}

func foobar(values: Number[] | Number | Null): Result {
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