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
	let x = foobar.__ks_0();
	if(Type.isValue(x)) {
		console.log(Helper.toString(x));
	}
	x = null;
	console.log(Helper.toString(x));
};