extern console

func foo(...args) {
	var dyn i = 42

	for i from 0 to~ args.length {
		console.log(args[i])
	}
}