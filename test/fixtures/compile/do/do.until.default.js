const {Operator} = require("@kaoscript/runtime");
module.exports = function() {
	do {
		sell();
	}
	while(!(Operator.gt(supply, demand)))
};