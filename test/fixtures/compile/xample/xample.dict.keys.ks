import '../_/_array.ks'

extern sealed class Dictionary {
	static keys(obj): Array<String>
}

func foo(x: Dictionary) => Dictionary.keys(x).last()