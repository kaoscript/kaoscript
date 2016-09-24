var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let __ks_0, __ks_1;
	let tt = Type.isValue((__ks_0 = foo(12, 42))) ? __ks_0 : Type.isValue((__ks_1 = bar(5, 6))) ? __ks_1 : qux(1, 3);
}