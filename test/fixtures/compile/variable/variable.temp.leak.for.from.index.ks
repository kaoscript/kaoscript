extern console

func foo(...args) {
	let i = 42
	
	for i from 0 til args.length {
		console.log(args[i])
	}
}