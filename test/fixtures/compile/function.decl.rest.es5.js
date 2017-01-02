module.exports = function() {
	function foo(bar) {
		if(bar === undefined || bar === null) {
			throw new Error("Missing parameter 'bar'");
		}
		let qux = Array.prototype.slice.call(arguments, 1, arguments.length);
	}
}