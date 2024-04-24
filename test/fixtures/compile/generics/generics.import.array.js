require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./.generics.export.array.ks.j5k8r9.ksb")().__ks_Array;
	const stack = [];
	stack.push("hello", "world");
	let value, __ks_0;
	if((Type.isValue(__ks_0 = stack.pop()) ? (value = __ks_0, true) : false)) {
		console.log(value);
	}
};