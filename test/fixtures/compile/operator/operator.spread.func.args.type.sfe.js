var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		let __ks_i = -1;
		let args = [];
		while(arguments.length > ++__ks_i) {
			if(Type.isString(arguments[__ks_i])) {
				args.push(arguments[__ks_i]);
			}
			else {
				throw new TypeError("'args' is not of type 'String'");
			}
		}
		return quxbaz.apply(null, [].concat(args));
	}
	function quxbaz(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
	}
};