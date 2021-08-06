local version = _VERSION:match("%d+%.%d+")

package.path  = package.path
.. '.luarocks/share/lua/' .. version .. '/?.lua;'

package.cpath = package.cpath
.. '.luarocks/lib/lua/' .. version .. '/?.so;'
.. '.luarocks/lib/lua/' .. version .. '/socket/?.so;'

package.path = package.path
.. '?.lua;'
.. 'scripts/lib/?.lua;'
.. 'scripts/sys_ctl/?.lua;'

