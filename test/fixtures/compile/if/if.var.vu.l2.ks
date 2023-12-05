extern test

var dyn foo = {
	message: 'hello'
}

if test {
	var dyn message

	if (message <- foo.message).length > 0 {
		echo(message)
	}
}