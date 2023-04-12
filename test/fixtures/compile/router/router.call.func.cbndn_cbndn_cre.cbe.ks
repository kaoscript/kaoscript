class ClassA {
}
class ClassB extends ClassA {
}

func foobar(x: ClassB? = null, y: ClassB? = null, z: ClassA) {
}

foobar(ClassB.new())