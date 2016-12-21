var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let __ks_0;
	let tt = (Type.isFunction(foo) && Type.isValue(__ks_0 = foo()) && Type.isFunction(__ks_0.bar)) ? __ks_0.bar() : undefined;
}