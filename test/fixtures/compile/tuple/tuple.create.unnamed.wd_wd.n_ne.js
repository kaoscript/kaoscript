var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.tuple(function(__ks_0, __ks_1) {
		if(__ks_0 === void 0 || __ks_0 === null) {
			__ks_0 = 0;
		}
		else if(!Type.isNumber(__ks_0)) {
			throw new TypeError("'__ks_0' is not of type 'Number'");
		}
		if(__ks_1 === void 0 || __ks_1 === null) {
			__ks_1 = 0;
		}
		else if(!Type.isNumber(__ks_1)) {
			throw new TypeError("'__ks_1' is not of type 'Number'");
		}
		return [__ks_0, __ks_1];
	});
	const pair = Pair();
};