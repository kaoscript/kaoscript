extern console

var dyn x = 3.14

for #[overwrite] var x in 0..10 {
	console.log(x)
}

console.log(x)