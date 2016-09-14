require expect: func

import * from ../compile/color.ks

let c = new Color('#ff0')

expect(c.red()).to.equal(255)
expect(c.green()).to.equal(255)
expect(c.blue()).to.equal(0)

c = new Color('rgb(255, 255, 0)')

expect(c.red()).to.equal(255)
expect(c.green()).to.equal(255)
expect(c.blue()).to.equal(0)