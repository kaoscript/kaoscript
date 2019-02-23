var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = {
		otto: "hello :)"
	};
	let bar = ["otto"];
	let qux, __ks_0;
	if(Type.isValue(foo[__ks_0 = bar.join(",")]) ? (qux = foo[__ks_0], true) : false) {
	}
};