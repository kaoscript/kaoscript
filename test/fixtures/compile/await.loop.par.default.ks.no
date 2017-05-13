func foo(values) async {
	const results = []
	
	for value in values {
		results.push(bar(value))
	}
	
	return baz(await* results)
}

func bar(value) async => value

func baz(values) => values