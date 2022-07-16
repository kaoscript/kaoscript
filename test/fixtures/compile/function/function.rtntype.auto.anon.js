const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function quzbaz() {
		return quzbaz.__ks_rt(this, arguments);
	};
	quzbaz.__ks_0 = function() {
		const foobar = (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(null);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function() {
				return "foobar";
			};
			return __ks_rt;
		})();
		console.log(foobar.__ks_0());
	};
	quzbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quzbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};