type User = {
	name: String
	supervisorId: Number?
}

extern {
	func parseInt(value: String): Number

	var repository: {
		findById(id: Number): User?
	}
}

func getSupervisorName(enteredId: string?): String? {
	return _.name
		?<| repository.findById
		?<| .supervisorId
		?<| repository.findById
		 <| parseInt
		?<| enteredId
}