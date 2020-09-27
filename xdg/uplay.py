#!/usr/bin/env python
import sys
import rendererconosle as rc
m = rc.Manager()
d = m.renderer_from_udn(sys.argv[1])
uri = d.host_file(sys.argv[2])
d.stop()
d.open_uri(uri)
d.play()
