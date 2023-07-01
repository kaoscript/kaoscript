const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y, z) => {
			if(z === void 0 || z === null) {
				z = 24;
			}
			return [x, y, z];
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length >= 2 && args.length <= 3) {
				if(t0(args[0]) && t0(args[1])) {
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
		return foo(1);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo(1, 2)).to.eql([1, 2, 24]);
	expect(Helper.function(() => {
		return foo(1, 2, 3, 4);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};