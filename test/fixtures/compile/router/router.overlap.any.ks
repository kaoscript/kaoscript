extern sealed class Date

impl Date {
	equals(value: Date): Boolean => this.getTime() == value.getTime()
	equals(value): Boolean => false
	equals(value?): Boolean => false
}