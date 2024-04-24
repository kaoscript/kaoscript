const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const stack = new Stack();
	stack.push(0, 2, 4);
	let value, __ks_0;
	if((Type.isValue(__ks_0 = stack.pop()) ? (value = __ks_0, true) : false)) {
		console.log(Helper.toString(value));
	}
};