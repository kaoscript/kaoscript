const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function build() {
		return build.__ks_rt(this, arguments);
	};
	build.__ks_0 = function() {
		return Helper.function(function() {
			return this.value;
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(that);
			}
			throw Helper.badArgs();
		});
	};
	build.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return build.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const fn = build.__ks_0();
	const obj = (() => {
		const o = new OBJ();
		o.value = 42;
		return o;
	})();
	expect(fn.call(obj)).to.eql(42);
};