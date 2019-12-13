var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!(Type.isClassInstance(x, Foobar) || Type.isString(x) || Type.isNumber(x))) {
			throw new TypeError("'x' is not of type 'Foobar', 'String' or 'Number'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if((y === 0) || Type.isString(x) || Type.isNumber(x)) {
			x = new Foobar();
		}
		quxbaz(x);
	}
	function quxbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isClassInstance(x, Foobar)) {
			throw new TypeError("'x' is not of type 'Foobar'");
		}
	}
};