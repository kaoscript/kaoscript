const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0);
	const x = Helper.default(__ks_0.x, 0, () => null);
};