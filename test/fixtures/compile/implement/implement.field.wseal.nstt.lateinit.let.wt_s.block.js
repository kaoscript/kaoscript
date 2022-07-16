module.exports = function(expect) {
	var __ks_Date = {};
	const d = new Date();
	expect(d.culture).to.not.exist;
	d.culture = "en";
	expect(d.culture).to.equal("en");
	const culture = d.culture;
	return {
		Date,
		__ks_Date
	};
};