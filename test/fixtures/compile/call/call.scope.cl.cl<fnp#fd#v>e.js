const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function build() {
		return build.__ks_rt(this, arguments);
	};
	build.__ks_0 = function(obj) {
		return Helper.function(() => {
			return obj.value;
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
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
	const fn = build.__ks_0(obj);
	expect(fn()).to.eql(42);
};