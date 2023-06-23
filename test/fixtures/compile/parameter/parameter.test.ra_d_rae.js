const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((items, x, values) => {
			if(x === void 0 || x === null) {
				x = 42;
			}
			return [items, x, values];
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return fn.call(null, [args[0]], void 0, [args[1]]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0])) {
					if(t0(args[1])) {
						if(t0(args[2])) {
							return fn.call(null, [args[0], args[1]], void 0, [args[2]]);
						}
					}
					if(t0(args[2])) {
						return fn.call(null, [args[0]], args[1], [args[2]]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 4) {
				if(t0(args[0])) {
					if(t0(args[1])) {
						if(t0(args[2])) {
							if(t0(args[3])) {
								return fn.call(null, [args[0], args[1], args[2]], void 0, [args[3]]);
							}
						}
						if(t0(args[3])) {
							return fn.call(null, [args[0], args[1]], args[2], [args[3]]);
						}
					}
					if(t0(args[2]) && t0(args[3])) {
						return fn.call(null, [args[0]], args[1], [args[2], args[3]]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 5) {
				if(t0(args[0])) {
					if(t0(args[1])) {
						if(t0(args[2])) {
							if(t0(args[4])) {
								return fn.call(null, [args[0], args[1], args[2]], args[3], [args[4]]);
							}
						}
						if(t0(args[3]) && t0(args[4])) {
							return fn.call(null, [args[0], args[1]], args[2], [args[3], args[4]]);
						}
					}
					if(t0(args[2]) && t0(args[3]) && t0(args[4])) {
						return fn.call(null, [args[0]], args[1], [args[2], args[3], args[4]]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 6) {
				if(t0(args[0]) && t0(args[1])) {
					if(t0(args[2])) {
						if(t0(args[4]) && t0(args[5])) {
							return fn.call(null, [args[0], args[1], args[2]], args[3], [args[4], args[5]]);
						}
					}
					if(t0(args[3]) && t0(args[4]) && t0(args[5])) {
						return fn.call(null, [args[0], args[1]], args[2], [args[3], args[4], args[5]]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 7) {
				if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[4]) && t0(args[5]) && t0(args[6])) {
					return fn.call(null, [args[0], args[1], args[2]], args[3], [args[4], args[5], args[6]]);
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo(1);
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo(1, 2)).to.eql([[1], 42, [2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2], 42, [3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 42, [4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3], 4, [5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], 4, [5, 6]]);
	expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3], 4, [5, 6, 7]]);
};