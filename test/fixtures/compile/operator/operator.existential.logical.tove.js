const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Operator.or(Type.isValue(foo) ? foo.foo : null, bar.bar);
};