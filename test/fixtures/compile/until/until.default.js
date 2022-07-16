const {Operator} = require("@kaoscript/runtime");
module.exports = function() {
	while(!Operator.gt(supply, demand)) {
		sell();
	}
};