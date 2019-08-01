extern console

extern class NS {
	#[rules(non-exhaustive)]
	static foobar()
}

console.log(NS.foobar('foobar'))

export NS