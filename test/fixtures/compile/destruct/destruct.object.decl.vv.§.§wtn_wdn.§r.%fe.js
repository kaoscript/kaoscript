const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_1;
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0, 1, Type.isValue, {x: Type.isValue, y: Type.any});
	const x = __ks_0.x, y = Helper.default(__ks_0.y, 0, () => null), rest = __ks_0.rest;
};