if getgenv().femboyvision then
	return
end

local Http = game:GetService("HttpService")
local Run = game:GetService("RunService")

local Games = {
	[7633926880] = { "bloxstrike", "89547431036819943263" },
	[7326934954] = { "bloxstrike", "89547431036819943263" },
	[114234929420007] = { "bloxstrike", "89547431036819943263" },
	[135434213652028] = { "bloxstrike", "89547431036819943263" },
	[108194354348181] = { "bloxstrike", "89547431036819943263" },
	[66654135] = { "prison fight", "97665761093805139305" },
	[7260680989] = { "prison fight", "97665761093805139305" },
	[135787580685512] = { "prison fight", "97665761093805139305" },
}

local Game = Games[game.GameId] or Games[game.PlaceId]
if not Game then
	return
end

local Pink = Color3.fromRGB(255, 105, 180)
local PinkMid = Color3.fromRGB(255, 160, 200)
local PinkEnd = Color3.fromRGB(255, 90, 160)
local Inline = Color3.fromRGB(35, 35, 35)
local Muted = Color3.fromRGB(180, 180, 180)

local function New(Class, Props)
	local Inst = Instance.new(Class)
	for Key, Value in next, Props do
		Inst[Key] = Value
	end
	return Inst
end

local function Outline(Parent)
	New("UIStroke", {
		Parent = Parent,
		Color = Color3.new(0, 0, 0),
		Thickness = 1,
		LineJoinMode = Enum.LineJoinMode.Miter,
	})
end

local function Request(Options)
	local Fn = getgenv().request or getgenv().http_request or request or http_request
	if type(Fn) ~= "function" and type(syn) == "table" then
		Fn = syn.request
	end
	if type(Fn) ~= "function" then
		return nil
	end
	local Ok, Res = pcall(Fn, Options)
	if not Ok or type(Res) ~= "table" then
		return nil
	end
	return {
		StatusCode = Res.StatusCode or Res.status_code or 0,
		Body = Res.Body or Res.body or "",
	}
end

local function FindNode()
	local Names = { "eu-1", "us-1" }
	for Index = 1, #Names do
		local Url = "https://" .. Names[Index] .. ".luaprot.net/api/v1/nodes/get"
		local Res = Request({
			Url = Url,
			url = Url,
			Method = "GET",
			method = "GET",
		})
		if Res and Res.StatusCode == 200 then
			local Ok, Data = pcall(Http.JSONDecode, Http, Res.Body)
			if Ok and type(Data) == "table" and type(Data.node) == "string" and Data.node ~= "" then
				return Data.node
			end
		end
	end
end

local function CheckKey(Node, Key)
	local Url = "https://" .. Node .. ".luaprot.net/api/v1/sdk/check"
	local Body = Http:JSONEncode({
		scriptId = Game[2],
		key = Key,
		placeId = game.PlaceId,
	})
	local Res = Request({
		Url = Url,
		url = Url,
		Method = "POST",
		method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		headers = { ["Content-Type"] = "application/json" },
		Body = Body,
		body = Body,
	})
	if not Res or Res.StatusCode ~= 200 then
		return nil, "check failed"
	end
	local Ok, Data = pcall(Http.JSONDecode, Http, Res.Body)
	if not Ok or type(Data) ~= "table" then
		return nil, "check failed"
	end
	if Data.status ~= "VALID" then
		return nil, tostring(Data.message or Data.status or "invalid key")
	end
	return Data
end

local function ReadKey()
	local Key = getgenv().lp_key
	if type(Key) ~= "string" and type(_G) == "table" then
		Key = _G.lp_key
	end
	if type(Key) ~= "string" then
		return nil
	end
	Key = Key:gsub("%s+", "")
	if Key == "" then
		return nil
	end
	return Key
end

local function ReadSerial(Data)
	local Env = getgenv()
	local Live = Env.LP_SERIAL
	if Live ~= nil and tostring(Live) ~= "" then
		return tostring(Live)
	end
	local KeyData = type(Data) == "table" and Data.keyData or nil
	if type(KeyData) ~= "table" then
		return nil
	end
	local Fields = { "serial", "uid", "keySerial" }
	for Index = 1, #Fields do
		local Value = KeyData[Fields[Index]]
		if Value ~= nil and tostring(Value) ~= "" then
			return tostring(Value)
		end
	end
end

local function ApplyKey(Key)
	getgenv().lp_key = Key
	if type(_G) == "table" then
		_G.lp_key = Key
	end
	lp_key = Key
end

local function LoadScript(Node, Key)
	ApplyKey(Key)
	local Got, Src = pcall(function()
		return game:HttpGet("https://" .. Node .. ".luaprot.net/api/v1/loaders/get/" .. Game[2])
	end)
	if not Got or type(Src) ~= "string" then
		return false, "loader failed"
	end
	local Fn, Err = loadstring(Src)
	if type(Fn) ~= "function" then
		return false, tostring(Err)
	end
	getgenv().femboyvision = true
	local Ok, RunErr = pcall(Fn)
	if not Ok then
		getgenv().femboyvision = nil
		return false, tostring(RunErr)
	end
	return true
end

local function RegisterFont(Name, Weight, Style, FaceWeight, Id, Url)
	if not writefile or not getcustomasset or not isfile then
		return nil
	end
	local Ok = pcall(function()
		if not isfile(Id) then
			writefile(Id, game:HttpGet(Url))
		end
		if isfile(Name .. ".font") then
			delfile(Name .. ".font")
		end
		writefile(Name .. ".font", Http:JSONEncode({
			name = Name,
			faces = {
				{
					name = "Regular",
					weight = Weight,
					style = Style,
					assetId = getcustomasset(Id),
				},
			},
		}))
	end)
	if not Ok then
		return nil
	end
	local FaceOk, Face = pcall(Font.new, getcustomasset(Name .. ".font"), FaceWeight, Enum.FontStyle.Normal)
	if FaceOk then
		return Face
	end
end

local function Fonts()
	local Title = RegisterFont(
		"OldTahomaBold",
		700,
		"normal",
		Enum.FontWeight.Bold,
		"old-tahoma-bold.ttf",
		"https://raw.githubusercontent.com/mental1illness/storage/refs/heads/main/fonts/old-tahoma-bold.ttf"
	)
	local Body = RegisterFont(
		"ProggyClean",
		200,
		"normal",
		Enum.FontWeight.Regular,
		"ProggyClean.ttf",
		"https://raw.githubusercontent.com/0x340/Priv9-UI-Libary/main/fonts/ProggyClean.ttf"
	)
	return Title or Font.fromEnum(Enum.Font.Code), Body or Font.fromEnum(Enum.Font.Code)
end

local function RichTitle(R, G, B)
	return '<font color="rgb(' .. R .. "," .. G .. "," .. B .. ')">femboy</font><font color="rgb(255,255,255)">vision</font>'
end

local function RichLine(Text)
	local Raw = tostring(Text or "")
	local Low = string.lower(Raw)
	local A, B = string.find(Low, "femboyvision", 1, true)
	if not A then
		return Raw
	end
	return '<font color="rgb(255,255,255)">' .. Raw:sub(1, A - 1) .. '</font><font color="rgb(255,105,180)">' .. Raw:sub(A, A + 5) .. '</font><font color="rgb(255,255,255)">' .. Raw:sub(A + 6, B) .. Raw:sub(B + 1) .. "</font>"
end

local function Show(Preset, Notice)
	local TitleFace, BodyFace = Fonts()
	local Core = game:GetService("CoreGui")
	if cloneref then
		Core = cloneref(Core)
	end
	local Gui = New("ScreenGui", {
		Name = "RobloxGui",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	if protectgui then
		protectgui(Gui)
	elseif type(syn) == "table" and syn.protect_gui then
		syn.protect_gui(Gui)
	end
	Gui.Parent = Core

	local Window = New("Frame", {
		Parent = Gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 280, 0, 146),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	})
	New("UIGradient", {
		Parent = Window,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Pink),
			ColorSequenceKeypoint.new(0.5, PinkMid),
			ColorSequenceKeypoint.new(1, PinkEnd),
		}),
	})

	local TitleBar = New("Frame", {
		Parent = Window,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 0, 20),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
	})
	local Title = New("TextLabel", {
		Parent = TitleBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		FontFace = TitleFace,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		Text = RichTitle(255, 105, 180),
		RichText = true,
	})
	Outline(Title)

	local Phase = 0
	local Grad = Run.RenderStepped:Connect(function(Dt)
		Phase = (Phase + Dt * 1.25) % 1
		local W = 0.3 + 0.35 * (0.5 + 0.5 * math.sin(Phase * math.pi * 2))
		Title.Text = RichTitle(
			math.floor((Pink.R * (1 - W) + W) * 255 + 0.5),
			math.floor((Pink.G * (1 - W) + W) * 255 + 0.5),
			math.floor((Pink.B * (1 - W) + W) * 255 + 0.5)
		)
	end)
	Gui.Destroying:Connect(function()
		Grad:Disconnect()
	end)

	local Body = New("Frame", {
		Parent = Window,
		Position = UDim2.new(0, 2, 0, 24),
		Size = UDim2.new(1, -4, 1, -26),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
	})
	local List = New("Frame", {
		Parent = Body,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(1, -12, 1, -12),
	})
	New("UIListLayout", {
		Parent = List,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local Enter = New("TextLabel", {
		Parent = List,
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		FontFace = BodyFace,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "enter key",
	})
	Outline(Enter)

	local Status = New("TextLabel", {
		Parent = List,
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		FontFace = BodyFace,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = Muted,
		Text = Notice or RichLine("enter the key to access femboyvision"),
		RichText = Notice == nil,
		TextWrapped = true,
	})
	Outline(Status)

	local BoxOuter = New("Frame", {
		Parent = List,
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = Pink,
		BorderSizePixel = 0,
	})
	New("Frame", {
		Parent = BoxOuter,
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = Inline,
		BorderSizePixel = 0,
	})
	local Box = New("TextBox", {
		Parent = BoxOuter,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -8, 1, 0),
		FontFace = BodyFace,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		PlaceholderColor3 = Color3.fromRGB(170, 170, 170),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ClearTextOnFocus = false,
	})
	Outline(Box)

	local Secret = Preset or ""
	local MaskLock = false
	local function PushMask()
		MaskLock = true
		Box.Text = string.rep("*", #Secret)
		MaskLock = false
	end
	PushMask()
	Box:GetPropertyChangedSignal("Text"):Connect(function()
		if MaskLock then
			return
		end
		local Text = Box.Text
		local Stars = string.rep("*", #Secret)
		if Text == Stars then
			return
		end
		if not string.find(Text, "*", 1, true) then
			Secret = Text
		elseif #Text < #Stars then
			Secret = Secret:sub(1, #Text)
		elseif Text:sub(1, #Stars) == Stars then
			Secret = Secret .. Text:sub(#Stars + 1)
		else
			Secret = Secret:sub(1, math.max(#Text - #Text:gsub("%*", ""), 0)) .. Text:gsub("%*", "")
			Secret = Secret:sub(1, #Text)
		end
		PushMask()
	end)

	local Button = New("TextButton", {
		Parent = List,
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = Pink,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	})
	New("Frame", {
		Parent = Button,
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = Inline,
		BorderSizePixel = 0,
		Active = false,
	})
	local ButtonText = New("TextLabel", {
		Parent = Button,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -8, 1, 0),
		FontFace = BodyFace,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "submit",
	})
	Outline(ButtonText)

	local Busy = false
	local Spinning = false
	local Frames = { "-", "/", "|", "\\" }
	local function StopSpin()
		Spinning = false
	end
	local function StartSpin()
		Spinning = true
		task.spawn(function()
			local Index = 1
			while Gui.Parent do
				if not Spinning then
					return
				end
				local Mark = Frames[Index]
				Status.Text = Mark .. " checking"
				ButtonText.Text = Mark
				Index = Index % #Frames + 1
				task.wait(0.1)
			end
		end)
	end
	local function Submit()
		if Busy then
			return
		end
		local Key = Secret:gsub("%s+", "")
		if Key == "" then
			Status.RichText = false
			Status.Text = "enter a key"
			return
		end
		Busy = true
		Status.RichText = false
		StartSpin()
		task.spawn(function()
			local Node = FindNode()
			if not Node then
				StopSpin()
				Busy = false
				ButtonText.Text = "submit"
				Status.Text = "no node"
				return
			end
			local Data, Reason = CheckKey(Node, Key)
			StopSpin()
			if not Data then
				Busy = false
				ButtonText.Text = "submit"
				Status.Text = Reason
				return
			end
			ApplyKey(Key)
			Status.Text = "welcome, uid " .. (ReadSerial(Data) or "-1")
			ButtonText.Text = "submit"
			task.delay(5, function()
				if Gui.Parent then
					Gui:Destroy()
				end
			end)
			task.spawn(function()
				local Clock = os.clock()
				while Gui.Parent and os.clock() - Clock < 5 do
					local Live = ReadSerial(Data)
					if Live then
						Status.Text = "welcome, uid " .. Live
						return
					end
					task.wait(0.1)
				end
			end)
			local Loaded, Err = LoadScript(Node, Key)
			if not Loaded and Gui.Parent then
				Status.Text = tostring(Err)
			end
		end)
	end

	Button.MouseButton1Click:Connect(Submit)
	Box.FocusLost:Connect(function(Enter)
		if Enter then
			Submit()
		end
	end)
end

local Key = ReadKey()
if Key then
	local Node = FindNode()
	if Node then
		local Data, Reason = CheckKey(Node, Key)
		if Data then
			ApplyKey(Key)
			local Loaded, Err = LoadScript(Node, Key)
			if Loaded then
				return
			end
			getgenv().femboyvision = nil
			Show(Key, tostring(Err))
			return
		end
		getgenv().femboyvision = true
		Show(Key, Reason)
		return
	end
end

getgenv().femboyvision = true
Show(Key)
