const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let  __ks_0 = foobar();
	Helper.assertDexArray(__ks_0, 1, 2, 0, 0, [() => true, Type.isValue]);
	const [x, y] = __ks_0;
};