const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new OBJ();
		d.otto = "hello :)";
		return d;
	})();
	let bar = ["otto"];
	let qux, __ks_0;
	if(Type.isValue(foo[__ks_0 = bar.join(",")]) ? (qux = foo[__ks_0], true) : false) {
	}
};