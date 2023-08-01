enum Color {
	Red
	Green
	Blue
}

class Foobar {
	test(color: Color): Boolean => false
	test(...colors: Color): Boolean => false
	foobar() {
		if @test(.Red) {
		}
	}
}