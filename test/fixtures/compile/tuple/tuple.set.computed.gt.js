var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.tuple(function(__ks_0, __ks_1) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(__ks_0 === void 0 || __ks_0 === null) {
			throw new TypeError("'__ks_0' is not nullable");
		}
		else if(!Type.isString(__ks_0)) {
			throw new TypeError("'__ks_0' is not of type 'String'");
		}
		if(__ks_1 === void 0 || __ks_1 === null) {
			throw new TypeError("'__ks_1' is not nullable");
		}
		else if(!Type.isNumber(__ks_1)) {
			throw new TypeError("'__ks_1' is not of type 'Number'");
		}
		return [__ks_0, __ks_1];
	});
	const pair = Pair("x", 0.1);
	console.log(pair[0], pair[1] + 1);
	pair[0] = "foobar";
	pair[1] = 3.14;
	console.log(pair[0], pair[1] + 1);
};