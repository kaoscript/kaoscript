const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Helper.function(() => {
		return "otto";
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	});
	let qux = Helper.function(() => {
		return "itti";
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	});
	let x;
	let __ks_0;
	if(Type.isValue(__ks_0 = foo.__ks_0()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
	else if(Type.isValue(__ks_0 = qux.__ks_0()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
};