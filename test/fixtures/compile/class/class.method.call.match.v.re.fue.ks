class Foobar {
	alt() => this.test(this.foobar())
	foobar():  String | Array<String> => ''
	test(token): Boolean => true
	test(...tokens): Boolean => true
}