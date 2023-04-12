require expect: func

import '../compile/color.ks'

var dyn c = Color.new('#ff0')

expect(c.red()).to.equal(255)
expect(c.green()).to.equal(255)
expect(c.blue()).to.equal(0)

c = Color.new('rgb(255, 255, 0)')

expect(c.red()).to.equal(255)
expect(c.green()).to.equal(255)
expect(c.blue()).to.equal(0)