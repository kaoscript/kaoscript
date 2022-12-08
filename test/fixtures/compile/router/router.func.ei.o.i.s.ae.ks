enum Color {
	Red
	Green
	Blue
}

func foobar(x: Color) => 'color'
func foobar(x: Object) => 'object'
func foobar(x: Number) => 'number'
func foobar(x: String) => 'string'
func foobar(x) => 'any'