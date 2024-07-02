const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Tester = Helper.alias(Type.isFunction);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};