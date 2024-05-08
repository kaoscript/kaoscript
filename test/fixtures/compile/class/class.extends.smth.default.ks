class Foobar {
	static {
		foobar(index, arr: Array) {
			var data = if index is Number set arr[index] else index

			return Quxbaz.foobar(index, data, arr)
		}
	}
}

class Quxbaz extends Foobar {
	static {
		foobar(index, data, arr: Array) {
		}
	}
}