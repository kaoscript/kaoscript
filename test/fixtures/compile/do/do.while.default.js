var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	do {
		buy();
	}
	while(Operator.gt(supply, demand))
};