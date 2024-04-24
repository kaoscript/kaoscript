const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return "foobar";
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const x = "barfoo";
	console.log(x);
	let __ks_x_1, __ks_0;
	if((Type.isValue(__ks_0 = foobar.__ks_0()) ? (__ks_x_1 = __ks_0, true) : false)) {
		console.log(Helper.toString(__ks_x_1));
	}
	console.log(x);
};