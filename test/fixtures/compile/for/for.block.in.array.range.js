var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	for(let __ks_0 = 0, __ks_1 = Helper.newArrayRange(0, 10, 1, true, true), __ks_2 = __ks_1.length, i; __ks_0 < __ks_2; ++__ks_0) {
		i = __ks_1[__ks_0];
		console.log(i);
	}
};