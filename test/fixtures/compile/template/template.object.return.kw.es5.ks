#![format(properties='es5')]

let x = 24

func foo() {
	return {
		`\(x)`: 42
	}
}