import '../_/_array.ks'

extern sealed class Object {
	static keys(obj): Array<String>
}

func foo(x: Object) => Object.keys(x).last()