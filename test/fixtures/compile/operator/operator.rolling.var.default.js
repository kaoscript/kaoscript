module.exports = function(Ellipse) {
	const shape = new Ellipse(10, 20);
	shape.rotation = (45 * Math.PI) / 180;
	shape.color = "rgb(0,129,198)";
	shape.outlineWidth = 0;
};