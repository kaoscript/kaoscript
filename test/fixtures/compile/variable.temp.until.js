module.exports = function() {
	function foo() {
		return false;
	}
	let x;
	while(!(x = foo())) {
		console.log(x);
	}
}