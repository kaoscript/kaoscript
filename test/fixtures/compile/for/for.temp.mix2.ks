extern console

func foo(x) {
	var dyn value, v

	if ?x.foo {
		for value in x.foo {
			match value.kind {
				42 {
					for v in value.values {
						console.log(value)
					}
				}
			}
		}
	}
}