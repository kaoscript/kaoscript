#![cfg(variables='es5')]

extern console

func foo(x) {
	if x.foo? {
		for value in x.foo {
			switch value.kind {
				42 => {
					for v in value.values {
						console.log(value)
					}
				}
			}
		}
	}
}