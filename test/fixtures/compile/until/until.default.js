var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	while(!Operator.gt(supply, demand)) {
		sell();
	}
};