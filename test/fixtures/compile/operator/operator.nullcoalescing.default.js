const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Type.isValue(x) ? x : y;
	let __ks_0;
	let bar = Type.isValue(__ks_0 = x()) ? __ks_0 : y;
	let qux = Type.isValue(x) ? x : Type.isValue(y) ? y : z;
};