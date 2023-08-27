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
	return null unless ?enteredId

	if var employee ?= repository.findById(parseInt(enteredId)) ;; ?employee.supervisorId {
		if var supervisor ?= repository.findById(employee.supervisorId!?) {
			return supervisor.name
		}
	}

	return null
}
