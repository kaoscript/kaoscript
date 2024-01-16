const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let y;
	let x;
	if(foo() === true) {
		x = 0;
	}
	else if(Type.isValue(y = bar())) {
		x = y;
	}
	else {
		x = 2;
	}
};