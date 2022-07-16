const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function xyz() {
		return xyz.__ks_rt(this, arguments);
	};
	xyz.__ks_0 = function() {
		return "xyz";
	};
	xyz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return xyz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let foo, __ks_0;
	if((Type.isValue(__ks_0 = xyz.__ks_0()) ? (foo = __ks_0, true) : false) && (Type.isValue(foo.bar) ? foo.bar.name === "xyz" : false) && Type.isValue(foo.qux)) {
		console.log(Helper.concatString("hello ", foo));
	}
};