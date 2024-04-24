func foobar(test, x = 'jane') {
	if test {
		#[overwrite] var dyn x = 'john'

		echo(x)
	}
}