func foobar(x, y) {
	var name = if x {
		match y {
			0 {
				set 'zero'
			}
			1 {
				set 'one'
			}
			else {
				set 'bye'
			}
		}
	}
	else {
		set 'bye'
	}

	echo(`\(name)`)
}