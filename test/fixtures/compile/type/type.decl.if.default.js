var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isBoolean(x)) {
			throw new TypeError("'x' is not of type 'Boolean'");
		}
		let y = null;
		if(x) {
			y = bar();
		}
		if(y !== null) {
			return y.z.toString();
		}
		else {
			return "";
		}
	}
	function bar() {
		return (() => {
			const d = new Dictionary();
			d.z = 42;
			return d;
		})();
	}
};