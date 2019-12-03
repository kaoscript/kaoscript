var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(__ks_function_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_function_1 === void 0 || __ks_function_1 === null) {
			throw new TypeError("'function' is not nullable");
		}
		else if(!Type.isNumber(__ks_function_1)) {
			throw new TypeError("'function' is not of type 'Number'");
		}
		const _ = new Dictionary();
		_.function = __ks_function_1;
		return _;
	});
	const s = Foobar(42);
};