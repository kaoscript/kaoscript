abstract class Type {
	abstract equals(b): Boolean
}

class FunctionType extends Type {
	equals(b?): Boolean { # {{{
		return true
	}
}