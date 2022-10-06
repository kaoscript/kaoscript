require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
var expect = require("chai").expect;
var disks = require("./.diskspace.module.ks.j5k8r9.ksb")().disks;
describe("diskspace", Helper.function(function() {
	it("print", Helper.function(function(done) {
		disks.__ks_0((__ks_e, __ks_0) => {
			const d = __ks_0;
			expect(d).to.have.length.above(0);
			console.log(d);
			done();
		});
	}, (fn, ...args) => {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(null, args[0]);
			}
		}
		throw Helper.badArgs();
	}, true));
}, (fn, ...args) => {
	if(args.length === 0) {
		return fn.call(null);
	}
	throw Helper.badArgs();
}));