const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		return {};
	});
	NS.foobar = function() {
		return NS.foobar.__ks_rt(this, arguments);
	};
	NS.foobar.__ks_0 = function() {
		return "foobar";
	};
	NS.foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return NS.foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(NS.foobar.__ks_0());
	return {
		NS
	};
};