import '../_/_array.ks'

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

var $available = []

export func acquire(): NS.Foobar {
	if $available.length == 0 {
		return NS.Foobar.new()
	}
	else {
		return $available.pop()!!
	}
}

export func release(item: NS.Foobar) {
	$available.push(item)
}