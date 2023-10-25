const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_1;
	let  __ks_0 = foobar();
	Helper.assertDexArray(__ks_0, 1, 1, 0, 0, [Type.isValue, Type.any]);
	const x = __ks_0[0], y = Helper.default(__ks_0[1], 0, () => null), rest = __ks_0.slice(2);
};