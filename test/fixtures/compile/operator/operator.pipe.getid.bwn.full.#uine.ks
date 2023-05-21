extern {
	func parseInt(value: String): Number
}

func getSupervisorId(enteredId: String?): Number? {
	return parseInt(_) ?<| enteredId
}