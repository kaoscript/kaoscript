const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function build() {
		return build.__ks_rt(this, arguments);
	};
	build.__ks_0 = function(value) {
		expect(this.value).to.eql(value);
		return value;
	};
	build.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return build.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const obj = (() => {
		const o = new OBJ();
		o.value = 42;
		return o;
	})();
	const fn = Helper.curry((that, fn, ...args) => {
		if(args.length === 0) {
			return fn[0]();
		}
		throw Helper.badArgs();
	}, () => build.__ks_0.call(obj, 42));
	expect(fn.__ks_0()).to.eql(42);
};