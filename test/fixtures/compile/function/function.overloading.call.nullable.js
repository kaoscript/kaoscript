var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		if(arguments.length === 1 && Type.isString(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return x;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0) {
				x = null;
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	console.log(foobar("foo"));
	console.log(Helper.toString(foobar(null)));
};