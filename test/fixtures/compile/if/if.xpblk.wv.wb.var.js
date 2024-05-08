const {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let y, __ks_0;
	let x;
	if(Type.isValue(__ks_0 = foo()) ? (y = __ks_0, true) : false) {
		for(let i = 1; i <= 10; ++i) {
			y = Operator.add(y, bar(i));
		}
		x = y;
	}
	else {
		x = bar();
	}
};