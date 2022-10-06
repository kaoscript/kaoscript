const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Helper.function(() => {
		return "otto";
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	});
	let qux = Helper.function(() => {
		return "itti";
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	});
	let x, __ks_0;
	if(Type.isValue(__ks_0 = foo.__ks_0()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
	else {
		if(Type.isValue(__ks_0 = qux.__ks_0()) ? (x = __ks_0, true) : false) {
			console.log(x);
		}
	}
};