const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let y, __ks_0;
	let x;
	if(foo() === true) {
		x = 0;
	}
	else if(Type.isValue(__ks_0 = bar()) ? (y = __ks_0, true) : false) {
		x = y;
	}
	else {
		x = 2;
	}
};