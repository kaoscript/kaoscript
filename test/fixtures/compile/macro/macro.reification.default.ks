macro build(@name: String, @amount: Number, @operator: String) {
	const args = [`x\(i)` for const i from 0 til amount]

	macro {
		func #w(name)#w(amount)(#a(args)) {
			return #j(args, operator)
		}
	}
}

build!('add', 3, ' + ')