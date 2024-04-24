const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0, 1, 0, {x: Type.any, y: Type.isValue});
	const {x, y} = __ks_0;
};