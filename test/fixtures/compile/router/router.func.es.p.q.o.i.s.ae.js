const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(String, "Clubs", "clubs", "Diamonds", "diamonds", "Hearts", "hearts", "Spades", "spades");
	const Pair = Helper.tuple(function(__ks_0, __ks_1) {
		return [__ks_0, __ks_1];
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	const Point = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return "card";
	};
	foobar.__ks_1 = function(x) {
		return "pair";
	};
	foobar.__ks_2 = function(x) {
		return "point";
	};
	foobar.__ks_3 = function(x) {
		return "object";
	};
	foobar.__ks_4 = function(x) {
		return "number";
	};
	foobar.__ks_5 = function(x) {
		return "string";
	};
	foobar.__ks_6 = function(x) {
		return "any";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isEnumInstance(value, CardSuit);
		const t2 = Type.isString;
		const t3 = value => Type.isTupleInstance(value, Pair);
		const t4 = value => Type.isStructInstance(value, Point);
		const t5 = Type.isObject;
		const t6 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_4.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_5.call(that, args[0]);
			}
			if(t3(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t4(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
			if(t5(args[0])) {
				return foobar.__ks_3.call(that, args[0]);
			}
			if(t6(args[0])) {
				return foobar.__ks_6.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};