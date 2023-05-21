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

func getSupervisorName(enteredId: String?): String? {
	return enteredId
		|>? parseInt(_)
		|>	repository.findById(_)
		|>? _.supervisorId
		|>?	repository.findById(_)
		|>? _.name
}