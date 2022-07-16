require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Qux = require("../export/.export.filter.class.nullable.ks.j5k8r9.ksb")().Qux;
	const q = Qux.__ks_new_0();
	let foo = q.__ks_func_foo_0();
	if(Type.isValue(foo)) {
		console.log(foo.__ks_func_toString_0());
	}
};