extern console

func foo(...args) {
	for i from 0 til args.length {
		console.log(args[i])
	}

	let j = 42

	for j from 0 til args.length {
		console.log(args[j])
	}

	for j from 0 til args.length {
		console.log(args[j])
	}
}