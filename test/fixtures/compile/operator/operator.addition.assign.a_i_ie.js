const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		x = Operator.add(x, y + z);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};