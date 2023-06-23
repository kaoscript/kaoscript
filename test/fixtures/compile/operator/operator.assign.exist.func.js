const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Helper.function(() => {
		return "otto";
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	});
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo.__ks_0()) ? bar = __ks_0 : null;
	console.log(foo, bar);
};