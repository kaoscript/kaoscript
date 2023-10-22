import '../_/_array.ks'

func foo(mut x, values) {
	if x is Array {
		echo(x.last())

		if values[x <- x.last()] {
			echo(x.last())
		}
		else {
			echo(x.last())
		}
	}
	else {
		echo(x.last())
	}
}