extern {
	func parseInt(value: String): Number
}

func getSupervisorId(enteredId: String?): Number? {
	return (if Number.isFinite(_) set _ else 0) <| parseInt(_) ?<| enteredId
}