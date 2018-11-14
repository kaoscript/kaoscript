import '../_/_array.ks'

extern console

impl Array {
	appendAny(...args): Array {
		console.log(args.last())

		for i from 0 til args.length {
			console.log(args[i].last())

			this.push(...args[i])
		}

		return this
	}

	appendArray(...args: Array): Array {
		console.log(args.last())

		for i from 0 til args.length {
			console.log(args[i].last())

			this.push(...args[i])
		}

		return this
	}
}