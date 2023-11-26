const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return 0;
	};
	foobar.__ks_1 = function(x) {
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Color);
		const t1 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};