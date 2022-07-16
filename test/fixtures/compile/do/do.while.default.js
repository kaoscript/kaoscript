const {Operator} = require("@kaoscript/runtime");
module.exports = function() {
	do {
		buy();
	}
	while(Operator.gt(supply, demand))
};