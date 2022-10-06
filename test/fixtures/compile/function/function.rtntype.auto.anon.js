const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function quzbaz() {
		return quzbaz.__ks_rt(this, arguments);
	};
	quzbaz.__ks_0 = function() {
		const foobar = Helper.function(function() {
			return "foobar";
		}, (fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
		console.log(foobar.__ks_0());
	};
	quzbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quzbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};