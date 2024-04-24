extern console

var dyn value = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for #[overwrite] var _, value of value {
	console.log(value)
}