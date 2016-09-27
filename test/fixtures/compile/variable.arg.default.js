module.exports = function() {
	function foo(foo) {
		if(foo === undefined || foo === null) {
			throw new Error("Missing parameter 'foo'");
		}
	}
	function bar() {
		return 42;
	}
	let x;
	foo(x = bar());
}