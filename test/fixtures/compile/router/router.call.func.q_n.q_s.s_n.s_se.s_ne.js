const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.struct(function(index, name) {
		const _ = new Dictionary();
		_.index = index;
		_.name = name;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
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
	foobar.__ks_0 = function(day, month) {
		return 0;
	};
	foobar.__ks_1 = function(day, month) {
		return 1;
	};
	foobar.__ks_2 = function(day, month) {
		return 2;
	};
	foobar.__ks_3 = function(day, month) {
		return 3;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = value => Type.isStructInstance(value, Weekday);
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1]);
				}
				if(t0(args[1])) {
					return foobar.__ks_3.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t2(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_0.call(that, args[0], args[1]);
				}
				if(t0(args[1])) {
					return foobar.__ks_1.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_2("", -1);
};