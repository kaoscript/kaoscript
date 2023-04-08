const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_1;
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0, 1, 0, {y: Type.isValue});
	const x = Helper.default(__ks_0.x, 0, () => null), y = __ks_0.y;
};