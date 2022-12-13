extern console

func foo(x) {
	if ?x.foo {
		for value in x.foo {
			switch value.kind {
				42 => {
					for i from 0 to~ value.values.length {
						console.log(value.values[i])
					}
				}
			}
		}
	}
}