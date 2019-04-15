class Foo {

}

class Bar extends Foo {

}

class Qux extends Foo {

}

func foo(x: Foo) {
	if x is Bar || x is Qux {

	}
	else {

	}
}