const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return Helper.function(() => {
			return this;
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(that);
			}
			throw Helper.badArgs();
		});
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};