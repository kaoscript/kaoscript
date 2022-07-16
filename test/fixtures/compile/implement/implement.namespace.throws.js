const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	NS.foobar = function() {
		return NS.foobar.__ks_rt(this, arguments);
	};
	NS.foobar.__ks_0 = function() {
		throw new Error();
	};
	NS.foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return NS.foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		NS
	};
};