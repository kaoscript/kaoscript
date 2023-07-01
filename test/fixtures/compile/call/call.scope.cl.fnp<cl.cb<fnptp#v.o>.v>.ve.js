const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function build() {
		return build.__ks_rt(this, arguments);
	};
	build.__ks_0 = function(value) {
		return Operator.multiplication(this.pi, value);
	};
	build.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return build.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const obj = (() => {
		const o = new OBJ();
		o.pi = 3.14;
		return o;
	})();
	const fn = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn[0](args[0]);
			}
		}
		throw Helper.badArgs();
	}, (__ks_0) => build.__ks_0.call(obj, __ks_0));
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function(value) {
		expect(fn(value)).to.eql(Operator.multiplication(3.14, value));
	};
	test.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return test.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	test.__ks_0(1);
};