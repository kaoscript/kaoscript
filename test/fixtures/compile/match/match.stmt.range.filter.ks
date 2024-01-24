func foobar(temperature: Number) {
	match temperature {
		0..49 	when temperature % 2 == 0	=> echo('Cold and even')
		50..79	when temperature % 2 == 0	=> echo('Warm and even')
		80..110	when temperature % 2 == 0	=> echo('Hot and even')
		else								=> echo('Temperature out of range or odd')
	}
}