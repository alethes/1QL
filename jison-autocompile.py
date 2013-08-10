import os.path, time
ot = 0
watch = [
    'test',
    'basic_lex.jison',
    'oneQL.coffee',
    'sql.coffee'
]
jisonext = '.jison'
jsext = '.js'
exe = 'basic_lex.js'
T = {}
for i in watch:
    T[i] = {'nt': 0, 'ot': 0}
while True:
    ran = False
    for f in watch:
        T[f]['nt'] = time.ctime(os.path.getmtime(f))
        if not ran and T[f]['nt'] != T[f]['ot']:
            print('\n\n\n\n\n\n\n')
            if jisonext in f:
                os.system('jison %s' % f)
                print('Compiled')
            os.system('node %s test' % (exe))
            ran = True
        T[f]['ot'] = T[f]['nt']
        time.sleep(.5)