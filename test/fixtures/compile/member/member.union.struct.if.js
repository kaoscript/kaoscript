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