import './variant.type.enum.export.lesson.ks'

func start(lesson: Lesson) {
	if lesson.students is Array {
		for var { name } in lesson.students {
			echo(`\(name)`)
		}
	}
	else {
		var group = lesson.students

		echo(`\(group.name)`)

		for var { name } in group.students {
			echo(`\(name)`)
		}
	}
}