local get_targets = ya.sync(function()
	local tab = cx.active
	local targets = {}

	if #tab.selected > 0 then
		for _, file in pairs(tab.selected) do
			targets[#targets + 1] = tostring(file.url)
		end
	elseif tab.current.hovered then
		targets[1] = tostring(tab.current.hovered.url)
	end

	return targets
end)

local function entry()
	local targets = get_targets()

	if #targets == 0 then
		return
	end

	local all_gdrive = true

	for _, path in ipairs(targets) do
		if path ~= "/mnt/gdrive" and not path:match("^/mnt/gdrive/") then
			all_gdrive = false
			break
		end
	end

	-- Google Drive dışı: tamamen normal Yazi davranışı
	if not all_gdrive then
		ya.emit("remove", {})
		return
	end

	-- Mount kökü kesinlikle silinemez
	for _, path in ipairs(targets) do
		if path == "/mnt/gdrive" then
			ya.notify {
				title = "Google Drive Trash",
				content = "/mnt/gdrive kok dizini silinemez",
				timeout = 5,
				level = "error",
			}
			return
		end
	end

	local body

	if #targets == 1 then
		body = ui.Text(
			"Google Drive Trash'e gonderilsin mi?\n\n" .. targets[1]
		):wrap(ui.Wrap.YES)
	else
		body = ui.Text(
			string.format(
				"%d oge Google Drive Trash'e gonderilsin mi?",
				#targets
			)
		):wrap(ui.Wrap.YES)
	end

	local yes = ya.confirm {
		pos = { "center", w = 70, h = 12 },
		title = "Google Drive Trash?",
		body = body,
	}

	if not yes then
		return
	end

	local cmd = { "/home/murat/.local/bin/gdrive-trash" }

	for _, path in ipairs(targets) do
		cmd[#cmd + 1] = string.format("%q", path)
	end

	ya.emit("shell", {
		table.concat(cmd, " "),
		block = true,
	})

	-- Silme bittikten sonra secimi temizle ve mevcut dizini yeniden yukle.
	ya.emit("escape", { "--select" })
	ya.emit("cd", { "." })
end

return { entry = entry }
