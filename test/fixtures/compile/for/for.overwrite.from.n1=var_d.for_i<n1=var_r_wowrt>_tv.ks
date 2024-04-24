extern console

var dyn x = 42

for #[overwrite] var x from 10 to 0 {
	console.log(x)
}

console.log(x)