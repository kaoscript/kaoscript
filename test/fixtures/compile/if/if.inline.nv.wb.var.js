const {Operator} = require("@kaoscript/runtime");
module.exports = function() {
	let x;
	if(foo() === true) {
		let y = 0;
		for(let i = 1; i <= 10; ++i) {
			y = Operator.add(y, bar(i));
		}
		x = y;
	}
	else {
		x = bar();
	}
};