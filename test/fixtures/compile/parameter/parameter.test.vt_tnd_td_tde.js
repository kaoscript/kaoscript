const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y = null, z, a) => {
			if(z === void 0 || z === null) {
				z = false;
			}
			if(a === void 0 || a === null) {
				a = 0;
			}
			return [x, y, z, a];
		}, (that, fn, ...args) => {
			const t0 = Type.isString;
			const t1 = value => Type.isString(value) || Type.isNull(value);
			const t2 = value => Type.isBoolean(value) || Type.isNull(value);
			const t3 = value => Type.isNumber(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 4) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && Helper.isVarargs(args, 0, 1, t3, pts, 2) && te(pts, 3)) {
					return fn.call(null, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo")).to.eql(["foo", null, false, 0]);
	expect(Helper.function(() => {
		return foo(true);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo(42);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar")).to.eql(["foo", "bar", false, 0]);
	expect(foo("foo", true)).to.eql(["foo", null, true, 0]);
	expect(foo("foo", 42)).to.eql(["foo", null, false, 42]);
	expect(Helper.function(() => {
		return foo("foo", []);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true, 0]);
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", false, 42]);
	expect(Helper.function(() => {
		return foo("foo", "bar", "qux");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", "bar", []);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", 42, "qux");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", true, "qux");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar", true, 42)).to.eql(["foo", "bar", true, 42]);
	expect(Helper.function(() => {
		return foo("foo", "bar", true, "qux");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};