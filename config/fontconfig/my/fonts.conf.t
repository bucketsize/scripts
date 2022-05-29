<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>

	<!-- Enable sub-pixel rendering --> 
	<match target="pattern">
	<!--
	  This configuration is available on the major desktop environments.
	  We shouldn't overwrite it with "assign" unconditionally.
	  Most clients may picks up the first value only. so using "append"
	  may simply works to avoid it.

	  Know what is the pixel format for your monitor, or else,
	  Go figure from: http://www.lagom.nl/lcd-test/subpixel.php
	-->
		<edit name="rgba" mode="append"><const>rgb</const></edit>
	</match>
 
 	<!-- Hint style -->
	<match target="pattern">
	<!--
	  This configuration is available on the major desktop environments.
	  We shouldn't overwrite it with "assign" unconditionally.
	  Most clients may picks up the first value only. so using "append"
	  may simply works to avoid it.
	-->
		<edit name="hintstyle" mode="append"><const>hintslight</const></edit>
	</match>

	<!-- alias / remap fonts to be used, replaced via scripts/config/config-global.lua -->
    <alias>
        <family>monospace</family>
        <prefer>
            <family>{font_family_monospace}</family>
        </prefer>
    </alias>
    <alias>
        <family>serif</family>
        <prefer>
            <family>{font_family_serif}</family>
        </prefer>
    </alias>
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>{font_family_sans}</family>
        </prefer>
    </alias>
</fontconfig>
