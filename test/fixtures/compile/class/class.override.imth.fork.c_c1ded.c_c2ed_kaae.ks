class ValueA {
}
class ValueB extends ValueA {
}

ValueA.Foobar = new ValueA()

enum EnumA {
	Foobar
}

class MainA {
	prepare(value: ValueA = ValueA.Foobar, mode: EnumA = EnumA::Foobar) {
	}
}

class MainB extends MainA {
	prepare(value: ValueB, mode: EnumA = EnumA::Foobar) {
	}
	override prepare(value, mode) {
	}
}