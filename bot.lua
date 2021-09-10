-- Modules
local discordia = require('discordia')
local client = discordia.Client()
local json = require('json')
local coro = require('coro-http')

-- config.json file setup
config = io.open("config.json", "r")
if config then
	config = json.parse(config:read())
else
	config = io.open("config.json", "w")
    config:write('{"token":"YOUR_BOT_TOKEN","prefix":"i!"}')
    config:close()
	config = io.open("config.json", "r")
    config = json.parse(config:read())
end

-- Some Variables
discordia.extensions()
token = config.token
prefix = config.prefix
if token == "YOUR_BOT_TOKEN" then
	print("Open config.json and replace YOUR_BOT_TOKEN with your Discord Bot Token. Visit https://discord.com/developers/applications")
	client:stop()
	return true
end
cd = ":white_check_mark: Please wait while I get the data!"

client:on('ready', function() -- on ready
	print('Logged in as '.. client.user.username)
	client:setGame{
		name = prefix.."help | by Adib23704#8947",
		type = 3 -- 0 - playing, 2 - listening, 3 - watching | Using 1 or higher than 3 (e.g: 4, 5) may crash your bot.
	}
end)

client:on('messageCreate', function(message)
	local content = message.content
	local member = message.member
	local memberid = message.member.id
	if memberid == client.user.id then return end
	local args = split(content, " ")
	local content = string.lower(content)
	if content:find(prefix..'insult')then
		Insult(message)
	end
	if content:find(prefix..'help') then
		help(message)
	end
	if content:find(prefix..'credit') or content:find(prefix..'credits') then
		credit(message)
	end
end)

function Insult(message)
	local mention = message.guild:getMember(message.mentionedUsers.first and message.mentionedUsers.first.id)
	local wait = message:reply(cd)
	local url = "https://evilinsult.com/generate_insult.php?lang=en&type=json"	
	if mention then
		local name = mention.user.mentionString
		local result, body = coro.request("GET", url)
		local data = json.parse(body)
		if string.find(data.insult, "&quot") or string.find(data.insult, "&gt") then
			local result, body = coro.request("GET", url)
			local data = json.parse(body)
		end
		wait:delete()
		if string.find(data.insult, "*") or string.find(data.insult, "`") or string.find(data.insult, "~") or string.find(data.insult, "_") or string.find(data.insult, "@") then -- markdown bypass
			message:reply("Hey " .. name .. ", \\" .. data.insult)
		else
			message:reply("Hey " .. name .. ", " .. data.insult)
		end
	else
		local member = message.member
		local name = member.user.mentionString
		local result, body = coro.request("GET", url)
		local data = json.parse(body)
		if string.find(data.insult, "&") then
			local result, body = coro.request("GET", url)
			local data = json.parse(body)
		end
		wait:delete()
		if string.find(data.insult, "*") or string.find(data.insult, "`") or string.find(data.insult, "~") or string.find(data.insult, "_") or string.find(data.insult, "@") then -- markdown bypass
			message:reply("Hey " .. name .. ", \\" .. data.insult)
		else
			message:reply("Hey " .. name .. ", " .. data.insult)
		end
	end
end

function help(message)
	local member = message.member
	message:reply {
		embed = {
			title = "InsultBot Commands - Prefix: `" .. prefix .. "`",
			color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
			description = "This bot is an open-source discord bot and made by Adib23704#8947\n\n*<> - Optional Parameter*",
			author = {
				name = member.username,
				icon_url = member.avatarURL
			},
			fields = {
				{
					name = "`"..prefix.."insult <@member>`",
					value = "Get Insulted! or insult someone!",
					inline = false,
				},
				{
					name = "`"..prefix.."help`",
					value = "This command!",
					inline = false,
				},
				{
					name = "`"..prefix.."credit`",
					value = "Get bot developer's info",
					inline = false,
				},
			},
			footer = {
				text = "InsultBot | https://adib23704.github.io"
			},
		},
		components = {
		    {
		        type = 1,
		        components = {
		            {
		                type = 2,
		                label = "Bot's Source Code on Github",
		                style = 5,
		                url = "https://github.com/Adib23704/InsultBot"
		            },
		            {
		                type = 2,
		                label = "Visit Developer",
		                style = 5,
		                url = "https://adib23704.github.io"
		            }
		        },
		    },
		},
	}
end

function credit(message)
	local member = message.member
	message:reply {
		embed = {
			title = "InsultBot Developer Info",
			color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
			description = "This bot is an open-source discord bot and made by Adib23704#8947",
			author = {
				name = member.username,
				icon_url = member.avatarURL
			},
			fields = {
				{
					name = "Developer",
					value = "Adib23704#8947",
					inline = true,
				},
				{
					name = "Thanks to",
					value = "[EvilInsult.com](https://evilinsult.com) for letting me use their API",
					inline = true,
				},
				{
					name = "⠀",
					value = "Developer's [Github](https://github.com/Adib23704) & [Website](https://adib23704.github.io)",
					inline = false,
				},
			},
			footer = {
				text = "InsultBot | By Adib23704#8947"
			},
		},
		components = {
		    {
		        type = 1,
		        components = {
		            {
		                type = 2,
		                label = "Bot's Source Code on Github",
		                style = 5,
		                url = "https://github.com/Adib23704/InsultBot"
		            }
		        },
		    },
		},
	}
end


function split(string, pattern) --From "deps/discordia/libs/extensions.lua"
    result = {}
    for match in (string..pattern):gmatch("(.-)"..pattern) do
        table.insert(result, match)
    end
    return result
end

client:run('Bot '.. token)