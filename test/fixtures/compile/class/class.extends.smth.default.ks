class Foobar {
	static {
		foobar(index, arr: Array) {
			var data = index is Number ? arr[index] : index

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