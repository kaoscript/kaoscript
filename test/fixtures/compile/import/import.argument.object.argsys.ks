require system class String

func corge(): Number => 42

func grault(n: Number): Number => n + 42

func garply(s: String): String => s.toLowerCase()

func waldo(): String => 'miss White'

export var foobar: {
	func corge(): Number
	func grault(n: Number): Number
	func garply(s: String): String
	func waldo(): String
} = {
	corge
	grault
	garply
	waldo
}