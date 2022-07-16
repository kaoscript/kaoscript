export namespace NS {
	export func foo() {
	}
	export func bar() {
	}
	export func qux() {
	}

	export class Foobar {
		private {
			_name: String	= ''
		}
		name() => @name
		name(@name) => this
	}
}

const $available = []

export func acquire(): NS.Foobar {
	if $available.length == 0 {
		return new NS.Foobar()
	}
	else {
		return $available.pop()!!
	}
}

export func release(item: NS.Foobar) {
	$available.push(item)
}