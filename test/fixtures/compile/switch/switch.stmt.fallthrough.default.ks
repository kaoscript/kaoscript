extern console

func foobar(d) {
	switch d {
		'hour' => {
			console.log('hour')

			fallthrough
		}
		'minute' => {
			console.log('minute')

			fallthrough
		}
		'second' => {
			console.log('second')
		}
	}
}