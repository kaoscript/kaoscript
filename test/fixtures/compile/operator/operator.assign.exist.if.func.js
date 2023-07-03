const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.otto = "hello :)";
		return o;
	})();
	let bar = ["otto"];
	let qux;
	let __ks_0;
	if(Type.isValue(foo[__ks_0 = bar.join(",")]) ? (qux = foo[__ks_0], true) : false) {
	}
};