extern console

var x = 42

for #[overwrite] var x from 10 to x {
	console.log(x)
}

console.log(x)