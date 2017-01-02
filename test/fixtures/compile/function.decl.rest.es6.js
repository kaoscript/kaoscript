module.exports = function() {
	function foo(bar, ...qux) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
	}
}