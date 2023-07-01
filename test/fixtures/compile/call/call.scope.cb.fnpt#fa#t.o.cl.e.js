const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function fn() {
		return fn.__ks_rt(this, arguments);
	};
	fn.__ks_0 = function() {
		this.foobar = 42;
		return Helper.function(() => {
			this.quxbaz = 24;
			return this;
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(that);
			}
			throw Helper.badArgs();
		});
	};
	fn.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return fn.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const obj = new OBJ();
	expect(fn.__ks_0.call(obj)()).to.eql(obj);
	expect(obj.foobar).to.eql(42);
	expect(obj.quxbaz).to.eql(24);
};