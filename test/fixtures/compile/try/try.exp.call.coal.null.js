const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(x === true) {
			return 42;
		}
		else {
			throw new Error("foobar");
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let __ks_0;
	expect(Type.isValue(__ks_0 = Helper.try(() => foobar.__ks_0(true), null)) ? __ks_0 : 24);
};