const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Qux = Helper.enum(Number, {
		abc: 0,
		def: 1,
		ghi: 2
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, filter) {
		let z = filter(x, y, Qux.abc);
		if(Type.isValue(z)) {
			return z;
		}
		return Operator.addOrConcat(x, y);
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