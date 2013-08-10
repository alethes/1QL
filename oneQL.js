(function() {
  var __slice = [].slice;

  this.oneQL = function() {
    this.l = function() {
      var a, n, _ref;

      n = arguments[0], a = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return console.log(n + ': \n', (_ref = require('util')).inspect.apply(_ref, __slice.call(a).concat([false], [10])));
    };
    this.backend = require('SQL');
    this.load = function(Tree) {
      this.Tree = Tree;
      this.l('Tree', Tree);
      return this.tokenize();
    };
    this.tokenize = function() {
      return this.getCollection();
    };
    this.getCollection = function() {
      var col;

      return col = this.Tree[0];
    };
    this.joins = {
      'LEFT_JOIN_ON': [5, '<', '<'],
      'LEFT_JOIN_BY_ID': [3, '<'],
      'RIGHT_JOIN_ON': [5, '>', '>'],
      'RIGHT_JOIN_BY_ID': [3, '>'],
      'INNER_JOIN_ON': [5, '>', '<'],
      'INNER_JOIN_BY_ID': [3, '<>'],
      'OUTER_JOIN_ON': [5, '>', '<'],
      'OUTER_JOIN_BY_ID': [3, '<>']
    };
    this.detectJoin = function(col) {
      var k, v, _ref;

      _ref = this.joins;
      for (k in _ref) {
        v = _ref[k];
        if (col.length === v[0] && v[1] === col[1] && ((v[2] == null) || v[2] === col[3])) {
          return this.backend.join(k, col);
        }
      }
      return col;
    };
    this.getConditions = function(cond) {
      console.log(cond);
      return cond;
    };
    this.condition = function(cond) {
      return this.backend.condition(cond);
    };
    this.operators = {
      '<': 'LT',
      '>': 'GT',
      '<=': 'LTE',
      '>=': 'GTE',
      '=': 'ASSIGN',
      '==': 'EQ'
    };
    this._operators = Object.keys(this.operators);
    this.isOperator = function(a) {
      if (this._operators.indexOf(a) === -1) {
        return false;
      }
      return this.operators[a];
    };
    return this;
  };

  module.exports = new this.oneQL();

}).call(this);
