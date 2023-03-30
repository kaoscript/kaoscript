type Foobar = Number | String | Array<Number | String> | Null

func foobar(x: Foobar) {
	match x {
		Array {
		}
		Number {
		}
		String {
		}
		else {
		}
	}
}