var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isFunction((__ks_0 = foo(), __ks_0.bar)) ? __ks_0.bar() : undefined;
}