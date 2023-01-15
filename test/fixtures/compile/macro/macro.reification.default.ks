macro build(@name: String, @amount: Number, @operator: String) {
	var args = [`x\(i)` for var i from 0 to~ amount]

	macro {
		func #w(name)#w(amount)(#a(args)) {
			return #j(args, operator)
		}
	}
}

build('add', 3, ' + ')