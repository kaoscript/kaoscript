const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	if((Type.isValue(foo) && Type.isValue(foo)) ? Operator.gt(foo.bar(), foo.qux()) : false) {
		console.log(foo);
	}
};