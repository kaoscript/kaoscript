const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 42;
	let __ks_0, __ks_1, __ks_2, __ks_3;
	[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 10, "", x, Infinity, "", 1);
	for(let __ks_4 = __ks_0, __ks_x_1; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
		__ks_x_1 = __ks_3(__ks_4);
		console.log(__ks_x_1);
	}
	console.log(x);
};