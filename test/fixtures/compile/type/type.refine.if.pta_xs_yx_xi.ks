extern console

func foobar() {
	let x, y

	if quxbaz(x = 'foobar') && quxbaz(y = x) && quxbaz(x = 42) {
		console.log(`\(x)`)
		console.log(`\(y)`)
	}

	console.log(`\(x)`)
	console.log(`\(y)`)
}

func quxbaz(x): Boolean => true