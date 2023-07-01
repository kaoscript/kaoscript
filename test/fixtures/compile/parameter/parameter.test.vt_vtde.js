const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y) => {
			if(y === void 0 || y === null) {
				y = "foobar";
			}
			return [x, y];
		}, (that, fn, ...args) => {
			const t0 = Type.isString;
			const t1 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return fn.call(null, args[0], args[1]);
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
	expect(foo("foo", "bar")).to.eql(["foo", "bar"]);
	expect(foo("foo", null)).to.eql(["foo", "foobar"]);
	expect(Helper.function(() => {
		return foo("foo", true);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};