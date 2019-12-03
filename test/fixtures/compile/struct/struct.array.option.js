var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.struct(function() {
		let __ks_i = -1;
		let __ks_0;
		if(arguments.length > ++__ks_i && (__ks_0 = arguments[__ks_i]) !== void 0 && __ks_0 !== null) {
			if(!Type.isString(__ks_0)) {
				if(arguments.length - __ks_i < 2) {
					__ks_0 = "";
					--__ks_i;
				}
				else {
					throw new TypeError("'__ks_0' is not of type 'String'");
				}
			}
		}
		else {
			__ks_0 = "";
		}
		let __ks_1;
		if(arguments.length > ++__ks_i && (__ks_1 = arguments[__ks_i]) !== void 0 && __ks_1 !== null) {
			if(!Type.isNumber(__ks_1)) {
				throw new TypeError("'__ks_1' is not of type 'Number'");
			}
		}
		else {
			__ks_1 = 0;
		}
		return [__ks_0, __ks_1];
	});
	const pair = Pair();
	const pair2 = Pair(null, 3.14);
	const pair3 = Pair("foobar");
	const pair4 = Pair("foobar", null);
	const pair5 = Pair(null, null);
};