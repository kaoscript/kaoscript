var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let ns = Helper.namespace(function() {
		function foo() {
			return 42;
		}
		return {
			foo: foo
		};
	});
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		return true;
	}
};