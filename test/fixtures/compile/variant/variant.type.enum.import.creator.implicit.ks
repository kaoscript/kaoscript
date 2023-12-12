import './variant.type.enum.export.default.ks'

func Student(name: String): SchoolPerson(Student) {
	return {
		kind: .Student
		name
	}
}