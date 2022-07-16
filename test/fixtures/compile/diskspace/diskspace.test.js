require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
var expect = require("chai").expect;
var disks = require("./.diskspace.module.ks.j5k8r9.ksb")().disks;
describe("diskspace", (() => {
	const __ks_rt = (...args) => {
		if(args.length === 0) {
			return __ks_rt.__ks_0.call(null);
		}
		throw Helper.badArgs();
	};
	__ks_rt.__ks_0 = function() {
		it("print", (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_rt.__ks_0.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function(done) {
				disks.__ks_0((__ks_e, __ks_0) => {
					let d = __ks_0;
					expect(d).to.have.length.above(0);
					console.log(d);
					done();
				});
			};
			return __ks_rt;
		})());
	};
	return __ks_rt;
})());