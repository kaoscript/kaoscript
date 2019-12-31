var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_0) {
	if(Type.isValue(__ks_0)) {
		Foobar = __ks_0;
	}
	Foobar.prototype.__ks_func_foobar_0 = function(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		return x;
	};
	Foobar.prototype.foobar = function() {
		if(arguments.length === 1) {
			return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Foobar: Foobar
	};
};