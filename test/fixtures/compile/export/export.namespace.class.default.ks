namespace NS {
	export func foo() {
	}
	export func bar() {
	}
	export func qux() {
	}

	export class Foobar {
		private {
			_name: String	 = ''
		}
		name(): String => @name
		name(@name) => this
	}
}

export NS