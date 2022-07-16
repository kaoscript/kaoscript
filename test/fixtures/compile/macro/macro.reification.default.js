const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function add3() {
		return add3.__ks_rt(this, arguments);
	};
	add3.__ks_0 = function(x0, x1, x2) {
		return Operator.addOrConcat(x0, x1, x2);
	};
	add3.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return add3.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};