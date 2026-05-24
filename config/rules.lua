-- ╔══════════════════════════════════════╗
-- ║           RULES                      ║
-- ╚══════════════════════════════════════╝

hl.config({
	layerrule = {
		"blur, waybar",
		"ignorealpha 0.3, waybar",
	},

	windowrulev2 = {
		-- pavucontrol
		"float,class:(pavucontrol)",
		"center,class:(pavucontrol)",
		"size 900 600,class:(pavucontrol)",
		"opacity 0.96 0.90,class:(pavucontrol)",

		-- network manager
		"float,class:(nm-connection-editor)",
		"center,class:(nm-connection-editor)",
		"opacity 0.96 0.90,class:(nm-connection-editor)",

		-- btop
		"float,title:(btop)",
		"center,title:(btop)",
		"size 1000 650,title:(btop)",
		"opacity 0.96 0.92,title:(btop)",

		-- htop
		"float,title:(htop)",
		"center,title:(htop)",
		"size 900 600,title:(htop)",
		"opacity 0.96 0.92,title:(htop)",

		-- SysMon (Yad)
		"float,title:(SysMon)",
		"center,title:(SysMon)",
		"size 420 280,title:(SysMon)",
		"opacity 0.96 0.92,title:(SysMon)",
		
		-- fastfetch
		"float,title:(fastfetch)",
		"center,title:(fastfetch)",
		"size 800 500,title:(fastfetch)",
		"opacity 0.96 0.92,title:(fastfetch)",

		"float,title:(binds)",
		"center,title:(binds)",
		"size 700 500,title:(binds)",
		"opacity 0.96 0.92,title:(binds)",
	},
})
