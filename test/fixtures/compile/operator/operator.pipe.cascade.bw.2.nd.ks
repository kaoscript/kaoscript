extern {
	func quxbaz
	func corge
}

func foobar(value?) {
	return corge
		?<| quxbaz
		 <| value
}