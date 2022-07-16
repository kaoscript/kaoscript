const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return quxbaz(x);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isBoolean(value) || Type.isNumber(value) || Type.isString(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
		return 1;
	};
	quxbaz.__ks_1 = function(x) {
		return 2;
	};
	quxbaz.__ks_2 = function(x, y) {
		if(y === void 0 || y === null) {
			y = 0;
		}
		return 3;
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		const t3 = value => Type.isNumber(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_2.call(that, args[0], void 0);
			}
			if(t1(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
			if(t2(args[0])) {
				return quxbaz.__ks_1.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t0(args[0]) && t3(args[1])) {
				return quxbaz.__ks_2.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};