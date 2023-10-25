const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_1;
	let  __ks_0 = foobar();
	Helper.assertDexArray(__ks_0, 1, 3, 0, 0, [Type.any, Type.isValue, Type.isValue]);
	const x = Helper.default(__ks_0[0], 1, () => 0), y = __ks_0[1], z = __ks_0[2];
};