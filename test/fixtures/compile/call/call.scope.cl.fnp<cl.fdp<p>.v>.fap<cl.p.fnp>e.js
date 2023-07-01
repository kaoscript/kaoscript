const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function use() {
		return use.__ks_rt(this, arguments);
	};
	use.__ks_0 = function(build) {
		const fns = [];
		build(Helper.function((fn) => {
			fns.push(fn);
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		}));
		for(let __ks_1 = 0, __ks_0 = fns.length, fn; __ks_1 < __ks_0; ++__ks_1) {
			fn = fns[__ks_1];
			fn(42);
		}
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
	use.__ks_0(Helper.function(function(add) {
		function assert() {
			return assert.__ks_rt(this, arguments);
		};
		assert.__ks_0 = function(value) {
			expect(value).to.eql(42);
		};
		assert.__ks_rt = function(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return assert.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		add(assert);
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