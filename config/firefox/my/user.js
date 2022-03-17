// blang line comment
user_pref("extensions.formautofill.addresses.enabled","false");
user_pref("extensions.formautofill.available","");
user_pref("extensions.formautofill.creditCards.available","false");
user_pref("extensions.formautofill.creditCards.enabled","false");
user_pref("extensions.formautofill.firstTimeUse","false");
user_pref("extensions.formautofill.heuristics.enabled","false");
user_pref("extensions.formautofill.section.enabled","false");
user_pref("extensions.pocket.api","");
user_pref("extensions.pocket.enabled","false");
user_pref("extensions.pocket.site","");
user_pref("extensions.screenshots.disabled","true");
user_pref("extensions.webcompat-reporter.enabled","false");
user_pref("media.navigator.enabled","false");
user_pref("media.peerconnection.enabled","false");
user_pref("network.cookie.cookieBehavior","3");
user_pref("network.cookie.lifetimePolicy","2");
user_pref("gfx.webrender.all","true");
user_pref("gfx.webrender.software","true");
user_pref("extensions.getAddons.discovery.api_url","");
user_pref("extensions.htmlaboutaddons.recommendations.enabled","false");
user_pref("browser.urlbar.autoFill","false");
user_pref("browser.urlbar.maxHistoricalSearchSuggestions","0");
user_pref("browser.urlbar.maxRichResults","0");
user_pref("toolkit.telemetry.reportingpolicy.firstRun","false");
user_pref("geo.enabled","false");
user_pref("geo.wifi.uri","");
user_pref("geo.wifi.xhr.timeout","1");
user_pref("dom.webnotifications.enabled","false");
user_pref("dom.gamepad.extensions.enabled","false");
user_pref("dom.push.enabled","false");
user_pref("network.dns.disablePrefetch","true");
user_pref("network.prefetch-next","false");
user_pref("browser.cache.disk.enable","false");
user_pref("browser.cache.offline.capacity","0");
user_pref("browser.cache.offline.enable","false");
user_pref("browser.cache.disk_cache_ssl","false");
user_pref("browser.cache.memory.enable","true");
user_pref("browser.cache.disk.smart_size.enabled","false");
user_pref("network.trr.mode","2");
user_pref("network.trr.uri","https://mozilla.cloudflare-dns.com/dns-query");
user_pref("network.dns.echconfig.enabled","true");
user_pref("network.dns.use_https_rr_as_altsvc","true");
user_pref("network.ftp.enabled","false");
user_pref("widget.non-native-theme.scrollbar.size","12 (default, scrollbar width) =&gt;");
user_pref("widget.non-native-theme.scrollbar.size.override","0");
user_pref("widget.non-native-theme.gtk.scrollbar.thumb-size","0.75");
user_pref("widget.non-native-theme.gtk.scrollbar.round-thumb","true");
user_pref("widget.non-native-theme.gtk.scrollbar.thumb-cross-size","40");
user_pref("dom.image-lazy-loading.enabled","true");

// Printer Settings Default off
user_pref("print.print_footerleft", "");
user_pref("print.print_footerright", "");
user_pref("print.print_headerleft", "");
user_pref("print.print_headerright", ""); 

// --
// -- https://github.com/pyllyukko/user.js/blob/master/user.js
// --

// PREF: Spoof dual-core CPU
// https://trac.torproject.org/projects/tor/ticket/21675
// https://bugzilla.mozilla.org/show_bug.cgi?id=1360039
user_pref("dom.maxHardwareConcurrency",				2);

// PREF: When webGL is enabled, do not expose information about the graphics driver
// https://bugzilla.mozilla.org/show_bug.cgi?id=1171228
// https://developer.mozilla.org/en-US/docs/Web/API/WEBGL_debug_renderer_info
user_pref("webgl.enable-debug-renderer-info",			false);
