enum Color {
	Red
	Green
	Blue
}

func test(color: Color): Boolean => false
func test(...colors: Color): Boolean => false

func foobar() {
	if test(.Red) {
	}
}