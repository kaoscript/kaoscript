const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let  __ks_0 = foobar();
	Helper.assertDexArray(__ks_0);
	const x = Helper.default(__ks_0[0], 0, () => null);
};