extern console

func foobar(d) {
	match d {
		'hour' {
			console.log('hour')

			fallthrough
		}
		'minute' {
			console.log('minute')

			fallthrough
		}
		'second' {
			console.log('second')
		}
	}
}