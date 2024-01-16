const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let x;
	let y = foo();
	if(Type.isValue(y)) {
		for(let i = 1; i <= 10; ++i) {
			y = Operator.add(y, bar(i));
		}
		x = y;
	}
	else {
		x = bar();
	}
};