var expect = require("chai").expect;
var disks = require("./diskspace.module.ks")().disks;
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
			console.log(d);
			done();
		});
	});
});