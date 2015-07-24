#!/usr/bin/env ruby

def list_themes
	s=`ls /usr/share/themes`
	puts s
end

def set_gtk_theme
	`gsettings set org.gnome.desktop.interface gtk-theme "#{ARGV[1]}"`
end

def set_wm_theme
	`gsettings set org.gnome.desktop.wm.preferences theme "#{ARGV[1]}"`
end

def method_missing(*args)
	
end

self.send ARGV[0]
