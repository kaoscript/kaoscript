import '../_/_string.ks'

impl String {
	endsWith(value: String): Boolean => this.length >= value.length && this.slice(this.length - value.length) == value
}

func clearer(current: number, value: string | number): number {
	if value is String && value:String.endsWith('%') {
		return current * ((100 - value.toFloat()) / 100)
	}
	else {
		return current - value.toFloat()
	}
}