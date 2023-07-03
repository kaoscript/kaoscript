extern console

func foo(...args) {
	var dyn i

	for i from 0 to~ args.length {
		console.log(args[i])
	}

	var dyn j = 42

	for j from 0 to~ args.length {
		console.log(args[j])
	}

	for j from 0 to~ args.length {
		console.log(args[j])
	}
}