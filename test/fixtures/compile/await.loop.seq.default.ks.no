func foo(values) async {
	const results = []
	
	for value in values {
		results.push(await bar(value))
	}
	
	return baz(results)
}

func bar(value) async => value

func baz(values) => values