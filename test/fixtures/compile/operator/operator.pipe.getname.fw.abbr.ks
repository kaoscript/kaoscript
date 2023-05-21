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
		|>? parseInt
		|>	repository.findById
		|>? .supervisorId
		|>? repository.findById
		|>? .name
}