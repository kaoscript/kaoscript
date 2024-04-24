const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_1;
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0, 1, 0, {x: Type.any, y: Type.isValue, z: Type.isValue});
	const x = Helper.default(__ks_0.x, 1, () => 0), y = __ks_0.y, z = __ks_0.z;
};