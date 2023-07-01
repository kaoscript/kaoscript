const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function use() {
		return use.__ks_rt(this, arguments);
	};
	use.__ks_0 = function(build) {
		const fn = build(42);
		expect(fn()).to.eql(42);
	};
	use.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return use.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	use.__ks_0(Helper.function(function(value) {
		return Helper.function(() => {
			return value;
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(null, args[0]);
			}
		}
		throw Helper.badArgs();
	}));
};