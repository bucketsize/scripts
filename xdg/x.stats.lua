lgi = require'lgi'
Gtk = lgi.require'Gtk'
dialog = Gtk.MessageDialog { text = 'This is a text message.', buttons = 'CLOSE' }
dialog:show_all()
Gtk.main()
