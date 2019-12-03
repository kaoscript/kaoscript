class Master {
}

class SubClassA extends Master {
}

class SubClassB extends Master {
}

class Disturb {

}

func foobar(x: SubClassA) {
}
func foobar(x: Master | Disturb) {
}