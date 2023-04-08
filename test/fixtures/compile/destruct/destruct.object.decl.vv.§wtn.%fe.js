const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let  __ks_0 = foobar();
	Helper.assertDexObject(__ks_0);
	const {x} = __ks_0;
};