const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isString(value) || Type.isNull(value));
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const regex = /foo/;
	let match, __ks_0;
	if((Type.isValue(__ks_0 = regex.exec("foobar")) ? (match = __ks_0, true) : false)) {
		foobar.__ks_0(match);
	}
};