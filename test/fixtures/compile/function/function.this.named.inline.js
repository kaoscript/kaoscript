const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		function fn() {
			return fn.__ks_rt(this, arguments);
		};
		fn.__ks_0 = function() {
			return this;
		};
		fn.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return fn.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		return fn;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};