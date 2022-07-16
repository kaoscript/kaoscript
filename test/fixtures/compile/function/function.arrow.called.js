const {Operator} = require("@kaoscript/runtime");
module.exports = function() {
	let four = ((a) => {
		return Operator.division(a, 10);
	})(42);
};