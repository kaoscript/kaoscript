module.exports = function() {
	function dot(foo) {
		if(foo === undefined || foo === null) {
			throw new Error("Missing parameter 'foo'");
		}
		return foo.bar;
	}
	function bracket(foo, bar) {
		if(foo === undefined || foo === null) {
			throw new Error("Missing parameter 'foo'");
		}
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
		return foo[bar];
	}
}