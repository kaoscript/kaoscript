module.exports = function(Ellipse, addShape) {
	let __ks_0;
	__ks_0 = new Ellipse(10, 20);
	__ks_0.rotation = (45 * Math.PI) / 180;
	__ks_0.color = "rgb(0,129,198)";
	__ks_0.outlineWidth = 0;
	addShape(__ks_0);
};