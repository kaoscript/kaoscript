const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y = null, z) => {
			return [x, y, z];
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return fn.call(null, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0]) && t0(args[2])) {
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
	expect(foo(1, 2)).to.eql([1, null, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3]);
	expect(Helper.function(() => {
		return foo(1, 2, 3, 4);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};