local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local WhitelistedHWIDs = { "8FEDA1DE-5918-41BF-B5F8-A90D0450617B" }
local qNVAKkuwxNpqruLjSRHg = false

function CheckHWID(hwidval)
	for _, whitelisted in pairs(WhitelistedHWIDs) do
		if hwidval == whitelisted then
			return true
		elseif hwidval ~= whitelisted then
			return false
		end
	end
end

qNVAKkuwxNpqruLjSRHg = CheckHWID(HWID)

if qNVAKkuwxNpqruLjSRHg == true then

end

--WEBHOOK SETUP HERE NERD!

local webh =
	"https://discord.com/api/webhooks/1049247984308731964/ojeaGAZv5GkxTGYS51GIuqU26N8veUJVuE9ZDwLiiztF8y3rf0th-_7zfDwXetKjksX8"

pcall(function()
	local data = {

		["embeds"] = {
			{
				["title"] = "`` | LOGIN ATTEMPT DENIED | ``",
				["description"] = "**Someone Has Executed You're Script**",
				["type"] = "rich",
				["color"] = tonumber(16753920),
				["fields"] = {
					{ name = "**Username**", value = game:GetService("Players").LocalPlayer.Name },
					{ name = "**Display Name**", value = game:GetService("Players").LocalPlayer.DisplayName },
					{ name = "**Player ID**", value = game:GetService("Players").LocalPlayer.UserId },
					{ name = "**Player Account Age**", value = game:GetService("Players").LocalPlayer.AccountAge },
					{ name = "**Hardware ID**", value = game:GetService("RbxAnalyticsService"):GetClientId() },
					{
						name = "**Ping**",
						value = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString(),
					},
					{ name = "**Executor**", value = identifyexecutor() },
				},
			},
		},
	}

	if syn then
		local response = syn.request({
			Url = webh,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = game:GetService("HttpService"):JSONEncode(data),
		})
	elseif request then
		local response = request({
			Url = webh,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = game:GetService("HttpService"):JSONEncode(data),
		})
	elseif http_request then
		local response = http_request({
			Url = webh,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = game:GetService("HttpService"):JSONEncode(data),
		})
	end
end)
