module.exports = function() {
	function foo() {
		return true;
	}
	let x;
	while(x = foo()) {
		console.log(x);
	}
}