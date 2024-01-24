const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		const result = [x];
		console.log(result[0]);
		result.push(y);
		console.log(Helper.toString(result[0]));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};