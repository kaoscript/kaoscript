var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = () => {
		return "otto";
	};
	let qux = () => {
		return "itti";
	};
	let x, __ks_0;
	if(Type.isValue(__ks_0 = foo()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
	else {
		if(Type.isValue(__ks_0 = qux()) ? (x = __ks_0, true) : false) {
			console.log(x);
		}
	}
};