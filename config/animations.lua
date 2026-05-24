-- ╔══════════════════════════════════════╗
-- ║            ANIMATIONS                ║
-- ╚══════════════════════════════════════╝

hl.curve("easeOut", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 6, bezier = "easeOut", style = "popin 80%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "easeOut", style = "slidefade 20%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "easeOut" })