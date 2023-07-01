const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
		const obj = (() => {
			const o = new OBJ();
			o.pi = 3.14;
			return o;
		})();
		for(let __ks_1 = 0, __ks_0 = fns.length, fn; __ks_1 < __ks_0; ++__ks_1) {
			fn = fns[__ks_1];
			fn.call(obj);
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
	function assert() {
		return assert.__ks_rt(this, arguments);
	};
	assert.__ks_0 = function(value) {
		expect(value).to.eql(42);
		expect(this.pi).to.eql(3.14);
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
	use.__ks_0(Helper.function(function(add) {
		add(Helper.curry((that, fn, ...args) => {
			if(args.length === 0) {
				return fn[0].call(that);
			}
			throw Helper.badArgs();
		}, function() {
			return assert.__ks_0.call(this, 42);
		}
));
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