const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_0;
	let tt = (Type.isValue(__ks_0 = foo()) && Type.isFunction(__ks_0.bar)) ? __ks_0.bar() : null;
};