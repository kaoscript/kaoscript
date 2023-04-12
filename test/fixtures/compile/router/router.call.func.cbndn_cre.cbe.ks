class ClassA {
}
class ClassB extends ClassA {
}

func foobar(x: ClassB? = null, y: ClassA) {
}

foobar(ClassB.new())