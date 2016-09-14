var expect = require("chai").expect;
var {Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type} = require("./polyfill.ks")();
var disks = require("./diskspace.module.ks")(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type).disks;
describe("diskspace", function() {
	it("print", function(done) {
		if(done === undefined || done === null) {
			throw new Error("Missing parameter 'done'");
		}
		disks((__ks_e, d) => {
			if(__ks_e) {
				return __ks_cb(__ks_e);
			}
			expect(d).to.have.length.above(0);
			done();
		});
	});
});