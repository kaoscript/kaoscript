module.exports = function() {
	function foo() {
		return "";
	}
	let x = "";
	console.log(x);
	x = foo();
	console.log(x);
	let y = 42;
	console.log("" + y);
	y = foo();
	console.log(y);
	return {
		foo: foo,
		x: x,
		y: y
	};
};