extern console

extern namespace NS {
	#[rules(non-exhaustive)]
	func foobar()
}

console.log(NS.foobar('foobar'))

export NS