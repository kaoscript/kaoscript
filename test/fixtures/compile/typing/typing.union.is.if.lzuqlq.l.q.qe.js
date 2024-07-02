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
	const Foobar = Helper.alias(value => Type.isStructInstance(value, Point) || Type.isArray(value, value => Type.isStructInstance(value, Point)));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		for(let __ks_1 = 0, __ks_0 = values.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = values[__ks_1];
			if(Type.isArray(value)) {
				for(let __ks_3 = 0, __ks_2 = value.length, vv; __ks_3 < __ks_2; ++__ks_3) {
					vv = value[__ks_3];
					quxbaz.__ks_0(vv);
				}
			}
			else {
				quxbaz.__ks_0(value);
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isStructInstance(value, Point) || Type.isArray(value, value => Type.isStructInstance(value, Point)));
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
	quxbaz.__ks_0 = function(value) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isStructInstance(value, Point);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};