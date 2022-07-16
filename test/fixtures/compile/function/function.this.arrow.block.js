const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		this.foobar = true;
		return (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(this);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = () => {
				this.arrow = true;
				return this;
			};
			return __ks_rt;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(foobar.__ks_0.call(new Dictionary())());
};