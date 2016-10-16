var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isValue(foo) && Type.isValue((__ks_0 = foo.bar(), __ks_0.qux)) ? __ks_0.qux.foo : undefined;
}