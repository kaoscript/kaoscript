const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(c1, c2, v2) {
		const v1 = v2.substring(Operator.add(v2.lastIndexOf(c1, (v2.contains(c2) === true) ? v2.indexOf(c2) : v2.length), 1), (v2.contains(c2) === true) ? v2.indexOf(c2, v2.lastIndexOf(c1, v2.indexOf(c2))) : v2.length);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};