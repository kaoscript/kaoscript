const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	for(let __ks_2 = Helper.newArrayRange(0, 10, 1, true, true), __ks_1 = 0, __ks_0 = __ks_2.length, i; __ks_1 < __ks_0; ++__ks_1) {
		i = __ks_2[__ks_1];
		console.log(i);
	}
};