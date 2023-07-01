const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y = null, z) => {
			if(z === void 0 || z === null) {
				z = false;
			}
			return [x, y, z];
		}, (that, fn, ...args) => {
			const t0 = Type.isString;
			const t1 = value => Type.isBoolean(value) || Type.isNull(value);
			const t2 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return fn.call(null, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0]) && t2(args[1]) && t1(args[2])) {
					return fn.call(null, args[0], args[1], args[2]);
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
	expect(Helper.function(() => {
		return foo("foo");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
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
	expect(foo("foo", true)).to.eql(["foo", null, true]);
	expect(foo("foo", null)).to.eql(["foo", null, false]);
	expect(Helper.function(() => {
		return foo("foo", "bar");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", 42);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false]);
	expect(Helper.function(() => {
		return foo("foo", "bar", "qux");
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("foo", "bar", 42);
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
};