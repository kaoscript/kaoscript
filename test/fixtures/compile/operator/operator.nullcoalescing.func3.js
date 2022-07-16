const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_0;
	let tt = Type.isValue(__ks_0 = foo(12, 42)) ? __ks_0 : Type.isValue(__ks_0 = bar(5, 6)) ? __ks_0 : qux(1, 3);
};