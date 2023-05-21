extern {
	func parseInt(value: String): Number
}

func getSupervisorId(enteredId: String?): Number? {
	return (Number.isFinite(_) ? _ : 0) <| parseInt ?<| enteredId
}