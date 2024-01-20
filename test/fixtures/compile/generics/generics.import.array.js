require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./.generics.export.array.ks.j5k8r9.ksb")().__ks_Array;
	const stack = [];
	stack.push("hello", "world");
	let value = stack.pop();
	if(Type.isValue(value)) {
		console.log(value);
	}
};