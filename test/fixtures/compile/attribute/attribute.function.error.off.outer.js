const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function error() {
		return error.__ks_rt(this, arguments);
	};
	error.__ks_0 = function() {
		throw new Error();
	};
	error.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return error.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		error.__ks_0();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};