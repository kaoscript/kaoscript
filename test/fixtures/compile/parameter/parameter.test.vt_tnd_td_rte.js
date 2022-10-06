const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y = null, z, args) => {
			if(z === void 0 || z === null) {
				z = false;
			}
			return [x, y, z, args];
		}, (fn, ...args) => {
			const t0 = Type.isString;
			const t1 = value => Type.isString(value) || Type.isNull(value);
			const t2 = value => Type.isBoolean(value) || Type.isNull(value);
			const t3 = Type.isNumber;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && Helper.isVarargs(args, 0, args.length - 1, t3, pts, 2) && te(pts, 3)) {
					return fn.call(this, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVarargs(args, pts[2], pts[3]));
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo")).to.eql(["foo", null, false, []]);
	expect(Helper.function(() => {
		return foo(true);
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo(42);
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar")).to.eql(["foo", "bar", false, []]);
	expect(foo("foo", true)).to.eql(["foo", null, true, []]);
	expect(foo("foo", 42)).to.eql(["foo", null, false, [42]]);
	expect(foo("foo", null)).to.eql(["foo", null, false, []]);
	expect(foo("foo", 42, 24, 18)).to.eql(["foo", null, false, [42, 24, 18]]);
	expect(Helper.function(() => {
		return foo("foo", []);
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true, []]);
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", false, [42]]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false, []]);
	expect(foo("foo", "bar", 42, 24, 18)).to.eql(["foo", "bar", false, [42, 24, 18]]);
	expect(foo("foo", null, null)).to.eql(["foo", null, false, []]);
	expect(Helper.function(() => {
		return foo("foo", "bar", "qux");
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", 42, "qux");
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", true, "qux");
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar", true, 42)).to.eql(["foo", "bar", true, [42]]);
	expect(foo("foo", "bar", true, 42, 24, 18)).to.eql(["foo", "bar", true, [42, 24, 18]]);
	expect(foo("foo", null, null, 42, 24, 18)).to.eql(["foo", null, false, [42, 24, 18]]);
};