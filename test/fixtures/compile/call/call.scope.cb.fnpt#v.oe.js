const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function fn() {
		return fn.__ks_rt(this, arguments);
	};
	fn.__ks_0 = function() {
		return this.value;
	};
	fn.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return fn.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const obj = (() => {
		const o = new OBJ();
		o.value = 42;
		return o;
	})();
	expect(fn.__ks_0.call(obj)).to.eql(42);
};