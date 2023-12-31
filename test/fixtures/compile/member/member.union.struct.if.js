const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const StructAB = Helper.struct(function(a, b, f) {
		const _ = new OBJ();
		_.a = a;
		_.b = b;
		_.f = f;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isBoolean;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2])) {
				return __ks_new(args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, StructAB)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.a)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.b)) {
			return null;
		}
		args[1] = arg;
		if(!Type.isBoolean(arg = item.f)) {
			return null;
		}
		args[2] = arg;
		return __ks_new.call(null, args);
	});
	const StructABC = Helper.struct(function(a, b, f, c) {
		const _ = new OBJ();
		_.a = a;
		_.b = b;
		_.f = f;
		_.c = c;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isBoolean;
		if(args.length === 4) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2]) && t0(args[3])) {
				return __ks_new(args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, StructABC)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.a)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.b)) {
			return null;
		}
		args[1] = arg;
		if(!Type.isBoolean(arg = item.f)) {
			return null;
		}
		args[2] = arg;
		if(!Type.isNumber(arg = item.c)) {
			return null;
		}
		args[3] = arg;
		return __ks_new.call(null, args);
	});
	const StructABD = Helper.struct(function(a, b, f, d) {
		const _ = new OBJ();
		_.a = a;
		_.b = b;
		_.f = f;
		_.d = d;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isBoolean;
		if(args.length === 4) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2]) && t0(args[3])) {
				return __ks_new(args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, StructABD)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.a)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.b)) {
			return null;
		}
		args[1] = arg;
		if(!Type.isBoolean(arg = item.f)) {
			return null;
		}
		args[2] = arg;
		if(!Type.isNumber(arg = item.d)) {
			return null;
		}
		args[3] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		if(data.f) {
			const x = data.a + data.b;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isStructInstance(value, StructABC) || Type.isStructInstance(value, StructABD);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};