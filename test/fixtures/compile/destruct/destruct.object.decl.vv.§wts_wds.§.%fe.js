const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_1;
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0, 1, 0, {x: value => Type.isString(value) || Type.isNull(value), y: Type.isValue});
	const x = Helper.default(__ks_0.x, 1, () => "", Type.isString), y = __ks_0.y;
};