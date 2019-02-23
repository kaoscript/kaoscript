#![format(functions='es5', properties='es5')]

let x := 'y'

let foo = {
	`\(x)`() {
		return 42
	}
}