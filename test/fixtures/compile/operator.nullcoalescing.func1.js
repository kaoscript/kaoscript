var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let __ks_0;
	let tt = Type.isValue(__ks_0 = foo(12, 42)) ? __ks_0 : bar;
};