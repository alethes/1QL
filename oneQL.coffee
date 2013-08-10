@oneQL =  ->
    @l = (n, a...) ->
        console.log n + ': \n', require('util').inspect(a..., false, 10)
    @backend = require 'SQL'
    @load = (Tree) ->
        @Tree = Tree
        @l 'Tree', Tree
        @tokenize()
    @tokenize = ->
        @getCollection()

    @getCollection = ->
        #@Tree[0] = _.flatten @Tree[0]
        col = @Tree[0]
        #join = @resolveJoins col
            #if not @isOperator i
            #    @resolveAlias i
    @joins =
        'LEFT_JOIN_ON': [5, '<', '<']
        'LEFT_JOIN_BY_ID': [3, '<']
        'RIGHT_JOIN_ON': [5, '>', '>']
        'RIGHT_JOIN_BY_ID': [3, '>']
        'INNER_JOIN_ON': [5, '>', '<']
        'INNER_JOIN_BY_ID': [3, '<>']
        'OUTER_JOIN_ON': [5, '>', '<']
        'OUTER_JOIN_BY_ID': [3, '<>']
    @detectJoin = (col) ->
        for k, v of @joins
            if col.length is v[0] and
            v[1] is col[1] and
            (not v[2]? or v[2] is col[3])
                return @backend.join k, col
        col

    @getConditions = (cond) ->
        console.log cond
        cond

    @condition = (cond) ->
        @backend.condition cond

    @operators = 
        '<': 'LT'
        '>': 'GT'
        '<=': 'LTE'
        '>=': 'GTE'
        '=': 'ASSIGN'
        '==': 'EQ'
    @_operators = Object.keys(@operators)
    @isOperator = (a) -> 
        return false if @_operators.indexOf(a) is -1
        @operators[a]
    @
module.exports = new @oneQL()