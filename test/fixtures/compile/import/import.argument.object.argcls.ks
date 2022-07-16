require class NewString

func corge(): Number => 42

func grault(n: Number): Number => n + 42

func garply(s: NewString): NewString => s.toLowerCase()

func waldo(): NewString => new NewString('miss White')

export const foobar: {
	func corge(): Number
	func grault(n: Number): Number
	func garply(s: NewString): NewString
	func waldo(): NewString
} = {
	corge
	grault
	garply
	waldo
}