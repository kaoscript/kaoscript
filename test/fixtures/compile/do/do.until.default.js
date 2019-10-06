var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	do {
		sell();
	}
	while(!(Operator.gt(supply, demand)))
};