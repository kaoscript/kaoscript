module.exports = function() {
	function foo(bar) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
	}
	function bar() {
		foo();
	}
}