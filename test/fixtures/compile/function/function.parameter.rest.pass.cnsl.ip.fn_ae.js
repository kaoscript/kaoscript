const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	ClassA.prototype.__ks_func_foobar_0 = function(args) {
		expect(args).to.eql(["abc", "def", "ghi", "jkl"]);
		items.push(...args);
	};
	ClassA.prototype.__ks_func_foobar_rt = function(that, proto, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return proto.__ks_func_foobar_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	ClassA.prototype.foobar = function() {
		return this.__ks_func_foobar_rt.call(null, this, this, arguments);
	};
	const a = ClassA.__ks_new_0();
	const items = [];
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		a.__ks_func_foobar_0.call(a, values);
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
	foobar.__ks_0(["abc", "def", "ghi", "jkl"]);
	expect(items).to.eql(["abc", "def", "ghi", "jkl"]);
};