require("kaoscript/register");
var expect = require("chai").expect;
var disks = require("./diskspace.module.ks")().disks;
describe("diskspace", function() {
	it("print", function(done) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(done === void 0 || done === null) {
			throw new TypeError("'done' is not nullable");
		}
		disks((__ks_e, d) => {
			expect(d).to.have.length.above(0);
			console.log(d);
			done();
		});
	});
});