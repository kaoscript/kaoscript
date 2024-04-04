module.exports = function(expect) {
	const __ks_Date = {};
	const d = new Date();
	expect(d.culture).to.not.exist;
	d.culture = "en";
	expect(d.culture).to.equal("en");
	const culture = d.culture;
	return {
		__ks_Date
	};
};