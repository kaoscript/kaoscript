const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y = null, z) => {
			if(z === void 0 || z === null) {
				z = false;
			}
			return [x, y, z];
		}, (fn, ...args) => {
			const t0 = Type.isString;
			const t1 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 2) {
				if(t0(args[0])) {
					return fn.call(this, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0]) && t1(args[1])) {
					return fn.call(this, args[0], args[1], args[2]);
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
	expect(Helper.function(() => {
		return foo("foo");
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
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
	expect(foo("foo", true)).to.eql(["foo", null, true]);
	expect(foo("foo", 42)).to.eql(["foo", null, 42]);
	expect(foo("foo", "bar")).to.eql(["foo", null, "bar"]);
	expect(foo("foo", null)).to.eql(["foo", null, false]);
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true]);
	expect(foo("foo", "bar", "qux")).to.eql(["foo", "bar", "qux"]);
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", 42]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false]);
};