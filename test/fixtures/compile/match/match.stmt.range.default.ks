func foobar(temperature: Number) {
	match temperature {
		0..49	=> echo('Cold')
		50..79	=> echo('Warm')
		80..110	=> echo('Hot')
		else	=> echo('Temperature out of range')
	}
}