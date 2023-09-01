var dyn x = 'y'

var dyn foo = {
	`\(x)`: func() {
		return 42
	}
}