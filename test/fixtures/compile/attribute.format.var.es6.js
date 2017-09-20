module.exports = function() {
	let x = 0;
	console.log(x);
	let o = {};
	o.x = 30;
	if(true) {
		let x = 42;
		console.log(x);
		if(true) {
			let x = 10;
			console.log(x);
		}
		console.log(x);
	}
	console.log(x);
	function foo() {
		let x = 5;
	}
};