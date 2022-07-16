const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.struct(function(ok, value) {
		const _ = new Dictionary();
		_.ok = ok;
		_.value = value;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isBoolean;
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let value;
		if((value = quxbaz.__ks_0()).ok === true) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};