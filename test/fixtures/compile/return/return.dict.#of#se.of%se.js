const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const d = new Dictionary();
			d.foobar = Helper.function(function() {
				return "";
			}, (fn, ...args) => {
				if(args.length === 0) {
					return fn.call(null);
				}
				throw Helper.badArgs();
			});
			return d;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};