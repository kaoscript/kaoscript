require("kaoscript/register");
var expect = require("chai").expect;
var disks = require("./diskspace.module.ks")().disks;
describe("diskspace", function() {
	it("print", function(done) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(done === void 0 || done === null) {
			throw new TypeError("'done' is not nullable");
		}
		disks((__ks_e, __ks_0) => {
			let d = __ks_0;
			expect(d).to.have.length.above(0);
			console.log(d);
			done();
		});
	});
});