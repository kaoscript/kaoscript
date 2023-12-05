const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let  __ks_0 = foobar();
	Helper.assertDexArray(__ks_0, 1, 3, 0, 0, [Type.isValue, Type.isValue, Type.isValue]);
	let [x, y, z] = __ks_0;
};