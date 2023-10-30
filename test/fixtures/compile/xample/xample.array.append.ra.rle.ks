import '../_/_array.ks'

extern console

impl Array {
	appendAny(...args): Array {
		console.log(args.last())

		for i from 0 up to~ args.length {
			if args[i] is Array {
				console.log(args[i].last())

				this.push(...args[i])
			}
			else {
				console.log(args[i])

				this.push(args[i])
			}
		}

		return this
	}

	appendArray(...args: Array): Array {
		console.log(args.last())

		for i from 0 up to~ args.length {
			console.log(args[i].last())

			this.push(...args[i])
		}

		return this
	}
}