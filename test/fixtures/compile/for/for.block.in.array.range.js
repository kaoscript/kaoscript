var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let __ks_0 = Helper.newArrayRange(0, 10, 1, true, true);
	for(let __ks_1 = 0, __ks_2 = __ks_0.length, i; __ks_1 < __ks_2; ++__ks_1) {
		i = __ks_0[__ks_1];
		console.log(i);
	}
};