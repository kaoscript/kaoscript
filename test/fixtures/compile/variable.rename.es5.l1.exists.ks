#![cfg(variables='es5')]

extern console, toUpperCase

func foobar(x = 'jane') {
	if true {
		let x = 'john'
		
		console.log(x.toUpperCase?)
	}
}