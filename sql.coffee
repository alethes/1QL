@SQL = ->
    @idField = ->
        'id'
    @tablecol = (t, c) ->
        @escape(t) + '.' + @escape(c)
    @escape = (n) ->
        '`' + n + '`'
    @name = (c) ->
        if typeof c isnt 'object'
            return @escape c
        else if c.length is 1
            return @escape c[0]
        else if c.length is 2
            @escape(c[0]) + ' AS ' + @escape(c[1])
    @joinUsing = (a, b, c) ->
        if a.length is 3
            ' ON (' + @tablecol(b[0], a[0]) + ' = ' + @tablecol(c[0], a[0]) + ')'
        else
            ' USING ' + a
    @condition = (cond) ->
        cond.join ' '
    @joins = 
        'LEFT_JOIN_BY_ID': (arg) ->
            n = if typeof arg[0] == 'object' then @name(arg[0]) else arg[0]
            n + ' LEFT JOIN ' + @name(arg[2]) + @joinUsing @escape @idField()
        'LEFT_JOIN_ON': (arg) ->
            @name(arg[0])  + ' LEFT JOIN ' + @name(arg[4]) + @joinUsing(arg[2], arg[0], arg[4])
    @join = (a, b) ->
        @joins[a].call @, b
    @

module.exports = new @SQL()