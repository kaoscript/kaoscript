var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = () => {
		return "otto";
	};
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo()) ? bar = __ks_0 : null;
	console.log(foo, bar);
};