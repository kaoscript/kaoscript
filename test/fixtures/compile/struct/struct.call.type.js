const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Point)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.y)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return "struct";
	};
	foobar.__ks_1 = function(x) {
		return "struct-instance";
	};
	foobar.__ks_2 = function(x) {
		return "any";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isStruct;
		const t1 = value => Type.isStructInstance(value, Point);
		const t2 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const point = Point.__ks_new(0.3, 0.4);
	foobar.__ks_0(Point);
	foobar.__ks_1(point);
};