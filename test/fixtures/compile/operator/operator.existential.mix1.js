var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	if(Type.isValue(foo) ? Operator.gt(foo.length, 10) : false) {
		console.log(foo);
	}
};