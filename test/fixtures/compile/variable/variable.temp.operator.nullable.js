var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let __ks_0;
	let tt = Type.isFunction((__ks_0 = foo(), __ks_0.bar)) ? __ks_0.bar() : null;
	let uu = Type.isFunction((__ks_0 = foo(), __ks_0.bar)) ? __ks_0.bar() : null;
};