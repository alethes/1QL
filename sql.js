(function() {
  this.SQL = function() {
    this.idField = function() {
      return 'id';
    };
    this.tablecol = function(t, c) {
      return this.escape(t) + '.' + this.escape(c);
    };
    this.escape = function(n) {
      return '`' + n + '`';
    };
    this.name = function(c) {
      if (typeof c !== 'object') {
        return this.escape(c);
      } else if (c.length === 1) {
        return this.escape(c[0]);
      } else if (c.length === 2) {
        return this.escape(c[0]) + ' AS ' + this.escape(c[1]);
      }
    };
    this.joinUsing = function(a, b, c) {
      if (a.length === 3) {
        return ' ON (' + this.tablecol(b[0], a[0]) + ' = ' + this.tablecol(c[0], a[0]) + ')';
      } else {
        return ' USING ' + a;
      }
    };
    this.condition = function(cond) {
      return cond.join(' ');
    };
    this.joins = {
      'LEFT_JOIN_BY_ID': function(arg) {
        var n;

        n = typeof arg[0] === 'object' ? this.name(arg[0]) : arg[0];
        return n + ' LEFT JOIN ' + this.name(arg[2]) + this.joinUsing(this.escape(this.idField()));
      },
      'LEFT_JOIN_ON': function(arg) {
        return this.name(arg[0]) + ' LEFT JOIN ' + this.name(arg[4]) + this.joinUsing(arg[2], arg[0], arg[4]);
      }
    };
    this.join = function(a, b) {
      return this.joins[a].call(this, b);
    };
    return this;
  };

  module.exports = new this.SQL();

}).call(this);
