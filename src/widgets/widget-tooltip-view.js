var View = require('cartodb.js').core.View
var _ = require('underscore')

/**
 * Standard widget tooltip view
 *
 */
module.exports = View.extend({
  className: 'CDB-Widget-tooltip',

  options: {
    attribute: 'data-tooltip',
    offsetX: 10,
    offsetY: -28
  },

  initialize: function (opts) {
    if (!opts.target) {
      throw new Error('target is not defined')
    }
    this._$target = this.options.target
    this._initBinds()
  },

  render: function () {
    var value = this._$target.attr(this.options.attribute)
    this.$el.html(value)
    return this
  },

  _initBinds: function () {
    this._$target.hover(
      _.bind(this.show, this),
      _.bind(this.hide, this)
    )
  },

  _setPosition: function () {
    var pos = this._$target.offset()
    var width = this.$el.outerWidth()

    this.$el.css({
      top: pos.top + this.options.offsetY,
      left: pos.left - (width / 2) + this.options.offsetX
    })
  },

  show: function () {
    this.render()
    this._setPosition()
    View.prototype.show.call(this)
  },

  clean: function () {
    this._$target.off('mouseenter mouseleave')
    View.prototype.clean.call(this)
  }

})
