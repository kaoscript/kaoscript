extern console

func foo(x) {
	var dyn value, i

	if ?x.foo {
		for value in x.foo {
			match value.kind {
				42 {
					for i from 0 to~ value.values.length {
						console.log(value.values[i])
					}
				}
			}
		}
	}
}