var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	if((Type.isValue(foo) && Type.isFunction(foo.bar) && Type.isValue(foo) && Type.isFunction(foo.qux)) ? Operator.gt(foo.bar(), foo.qux()) : false) {
		console.log(foo);
	}
};