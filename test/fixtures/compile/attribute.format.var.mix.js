module.exports = function() {
	let x = 0;
	console.log(x);
	if(true) {
		let x = 42;
		console.log(x);
	}
	console.log(x);
	if(true) {
		var __ks_x_1 = 24;
		console.log(__ks_x_1);
	}
	console.log(x);
	if(true) {
		let x = 10;
		console.log(x);
	}
	console.log(x);
}