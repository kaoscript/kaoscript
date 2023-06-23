const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c, d, e, f, g, h, i, j) {
		let __ks_0;
		if(Operator.lt(a(), __ks_0 = b()) && Operator.lte(__ks_0, __ks_0 = c()) && Operator.lt(__ks_0, __ks_0 = d()) && __ks_0 === (__ks_0 = e()) && Operator.gt(__ks_0, __ks_0 = f()) && Operator.gte(__ks_0, __ks_0 = g()) && __ks_0 === (__ks_0 = h()) && Operator.lt(__ks_0, __ks_0 = i()) && __ks_0 !== j()) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 10) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && t0(args[4]) && t0(args[5]) && t0(args[6]) && t0(args[7]) && t0(args[8]) && t0(args[9])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(Helper.function(() => {
		return 1;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 2;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 2;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 3;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 3;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 2;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 1;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 1;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 3;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}), Helper.function(() => {
		return 5;
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}));
};