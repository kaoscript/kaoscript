const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.enum(Number, {
		A: 0,
		B: 1,
		C: 2
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(m) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(Foobar(Foobar.A | Foobar.C));
};