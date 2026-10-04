--[[
    ╔════════════════════════════════════════════════════════════════╗
    ║                       (S)Unique HUB                            ║
    ║               Silas V1 Engine • WarZ / BloxZ Edition           ║
    ║                  Premium Monochrome Dark Theme                 ║
    ║                                                                ║
    ║   Features:                                                    ║
    ║   1. Custom Config Manager (ตั้งชื่อ, เลือก, บันทึก, โหลด)       ║
    ║   2. Target Health HUD Real-time (หลอดเลือดเป้าหมายเรียลไทม์)   ║
    ║   3. Dropped Item ESP + Filters (ESP ไอเทมตกพื้น + กรองประเภท)  ║
    ║   4. FOV Circle Slider (ปรับขนาดวงเล็งแบบหลอดเลื่อน)           ║
    ║   5. Movement: Speed Hack, Infinite Stamina, Noclip            ║
    ║   6. Aimbot (Smooth Cam, Hard Lock, Mouse Delta, No Drop)      ║
    ║   7. Hitbox Expander (ขยายหัว Head Hitbox)                     ║
    ║   8. Player ESP, Box ESP, Tracers, Health Bar                  ║
    ║   9. Combat: Auto Heal, Back Alert 20M, Instant Pickup         ║
    ║   10. Loot WarZ: Item Magnet, Teleport Loot, Auto Aura         ║
    ║   11. Keybind [X] ย่อ/ขยายหน้าต่าง UI                          ║
    ╚════════════════════════════════════════════════════════════════╝
--]]

-- แจ้งเตือนเริ่มต้นทันทีที่กดรัน (ให้ผู้ใช้ทราบว่าสคริปต์เริ่มทำงานแล้ว)
print("[(S)Unique HUB] กำลังเริ่มต้นทำงาน...")
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "(S)Unique HUB",
        Text = "กำลังโหลดระบบ... กรุณารอสักครู่",
        Duration = 3
    })
end)


-- ������������������ KEY SYSTEM INJECTION ������������������
--[[
    ╔════════════════════════════════════════════════════════════════╗
    ║                 UNIVERSAL KEY SYSTEM & HWID LOCK               ║
    ║           ระบบตรวจสอบคีย์ + ล็อค HWID + บันทึกจำคีย์อัตโนมัติ        ║
    ║                                                                ║
    ║   Features:                                                    ║
    ║   1. รองรับ GitHub Raw URL และ GitHub REST API                 ║
    ║   2. HWID Lock ป้องกันส่งต่อคีย์ (1 คีย์ใช้งานได้ 1 เครื่อง)          ║
    ║   3. GitHub Auto-Commit ผูก HWID ขึ้น GitHub อัตโนมัติ           ║
    ║   4. ระบบ Remember Key / Auto-Login เข้าอัตโนมัติเมื่อเคยใส่แล้ว    ║
    ║   5. UI ทันสมัย เลื่อนย้ายหน้าต่างได้ (Draggable) + ปุ่ม Copy HWID ║
    ║   6. รองรับ Executors ทุกค่าย (Delta, Fluxus, Codex, Solara ฯลฯ) ║
    ╚════════════════════════════════════════════════════════════════╝
--]]

local KeySystem = {}
KeySystem.__index = KeySystem

-- ══════════════════════════════════════════════════════════════
-- [ ⚙️ CONFIGURATION: ตั้งค่าระบบคีย์ที่นี่ ]
-- ══════════════════════════════════════════════════════════════
KeySystem.Config = {
    -- ชื่อ Hub / สคริปต์ที่จะแสดงบนหัว UI
    HubName = "Unique HUB",
    Subtitle = "KEY SYSTEM • 1 KEY PER 1 DEVICE",

    -- ลิงก์ไฟล์ keys.txt ดิบ (Raw) บน GitHub
    KeysUrl = "https://raw.githubusercontent.com/Un1queHUB/Project-S/refs/heads/main/pskeys.txt",

    -- ข้อมูล GitHub สำหรับระบบ Auto-Commit (ผูก HWID ขึ้น GitHub อัตโนมัติเมื่อมีคนใช้คีย์ใหม่)
    GitHubOwner = "SilasTH2449",     -- ชื่อผู้ใช้ GitHub
    GitHubRepo  = "Auto-Fishing",     -- ชื่อ Repository
    GitHubPath  = "keys.txt",         -- พาธของไฟล์คีย์ใน Repo

    --[[
        [ วิธีสร้าง GitHub Token เพื่อให้ระบบล็อค HWID ขึ้น GitHub อัตโนมัติ ]
        1. ไปที่ https://github.com/settings/tokens?type=beta (Fine-grained tokens)
        2. กด "Generate new token" ตั้งชื่อ เช่น "KeySystemToken"
        3. หัวข้อ Repository access: เลือก "Only select repositories" แล้วเลือก Repo คีย์ของคุณ
        4. หัวข้อ Permissions -> Repository permissions -> Contents: เลือก "Read and write"
        5. กด Generate แล้วนำ Token (เช่น github_pat_xxxx) มาวางในช่อง GitHubToken ด้านล่าง
        * หากไม่ใส่ Token ("") แอดมินสามารถนำ HWID ของลูกค้าไปพิมพ์ใส่ใน keys.txt เองได้ (รูปแบบ KEY:HWID)
    --]]
    GitHubToken = "", -- ?? ��� Token �ͧ GitHub �������������Ѿഷ����ѵ��ѵ�

    -- หากเป็น true: คีย์บน GitHub จะต้องมี :HWID เท่านั้นถึงจะเข้าได้ (ป้องกันคนเอาคีย์ว่างไปแชร์กัน)
    -- หากเป็น false: อนุญาตให้คีย์ที่ยังไม่มี :HWID ถูกผูกกับเครื่องแรกที่นำไปใช้
    StrictHwidOnly = true,

    -- ชื่อไฟล์เซฟคีย์ในเครื่องของผู้ใช้ (แต่ละสคริปต์ควรตั้งชื่อไม่ให้ซ้ำกัน)
    SaveFileName = "UniqueHub_SavedKey.json",

    -- ลิงก์รับคีย์ หรือ ลิงก์ Discord (หากใส่ จะมีปุ่ม "🔑 รับคีย์" ขึ้นมา / หากไม่ต้องการให้ใส่เป็น "")
    GetKeyUrl = "",

    -- เปิดใช้งานระบบล็อกอินอัตโนมัติ (จำคีย์ไม่ต้องกรอกใหม่ทุกรอบ)
    AutoLogin = true,
}

-- ══════════════════ SERVICES ══════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local StarterGui       = game:GetService("StarterGui")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)

-- ══════════════════ GUI PARENT RESOLVER ══════════════════
local function getSafeGuiParent()
    local parent = nil
    pcall(function()
        if gethui then
            parent = gethui()
        elseif CoreGui then
            parent = CoreGui
        end
    end)
    if not parent then
        parent = PlayerGui
    end
    return parent
end

-- ══════════════════ THEME / UI COLORS ══════════════════
local Theme = {
    BG          = Color3.fromRGB(18, 18, 22),
    Header      = Color3.fromRGB(24, 24, 30),
    Card        = Color3.fromRGB(26, 26, 33),
    CardHover   = Color3.fromRGB(34, 34, 42),
    Border      = Color3.fromRGB(48, 48, 58),
    BorderLight = Color3.fromRGB(70, 70, 84),
    Text        = Color3.fromRGB(245, 245, 248),
    TextMuted   = Color3.fromRGB(150, 150, 162),
    Green       = Color3.fromRGB(46, 204, 113),
    GreenHover  = Color3.fromRGB(39, 174, 96),
    Red         = Color3.fromRGB(231, 76, 60),
    RedHover    = Color3.fromRGB(192, 57, 43),
    Yellow      = Color3.fromRGB(241, 196, 15),
    Accent      = Color3.fromRGB(230, 230, 235),
    White       = Color3.fromRGB(255, 255, 255),
}

-- ══════════════════ UI BUILDER HELPERS ══════════════════
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function RoundCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

-- ══════════════════ BASE64 ENGINE ══════════════════
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64lookup = {}
for i = 1, #b64chars do
    b64lookup[b64chars:sub(i, i)] = i - 1
end

local function base64Encode(str)
    local bytes = {str:byte(1, #str)}
    local result = {}
    local pad = 3 - (#bytes % 3)
    if pad == 3 then pad = 0 end
    for i = 1, pad do
        table.insert(bytes, 0)
    end
    for i = 1, #bytes, 3 do
        local b1, b2, b3 = bytes[i], bytes[i+1], bytes[i+2]
        local n = (b1 * 65536) + (b2 * 256) + b3
        local c1 = math.floor(n / 262144) % 64 + 1
        local c2 = math.floor(n / 4096) % 64 + 1
        local c3 = math.floor(n / 64) % 64 + 1
        local c4 = n % 64 + 1
        table.insert(result, b64chars:sub(c1, c1))
        table.insert(result, b64chars:sub(c2, c2))
        table.insert(result, b64chars:sub(c3, c3))
        table.insert(result, b64chars:sub(c4, c4))
    end
    local res = table.concat(result)
    if pad > 0 then
        res = res:sub(1, #res - pad) .. string.rep("=", pad)
    end
    return res
end

local function base64Decode(data)
    data = string.gsub(data, "[^A-Za-z0-9+/=]", "")
    local result = {}
    local len = #data
    local i = 1
    while i <= len do
        local c1 = b64lookup[data:sub(i, i)] or 0
        local c2 = b64lookup[data:sub(i+1, i+1)] or 0
        local c3 = b64lookup[data:sub(i+2, i+2)] or 0
        local c4 = b64lookup[data:sub(i+3, i+3)] or 0

        local pad = 0
        if data:sub(i+2, i+2) == "=" then pad = 2
        elseif data:sub(i+3, i+3) == "=" then pad = 1 end

        local n = (c1 * 262144) + (c2 * 4096) + (c3 * 64) + c4
        local b1 = math.floor(n / 65536) % 256
        local b2 = math.floor(n / 256) % 256
        local b3 = n % 256

        table.insert(result, string.char(b1))
        if pad < 2 then table.insert(result, string.char(b2)) end
        if pad < 1 then table.insert(result, string.char(b3)) end

        i = i + 4
    end
    return table.concat(result)
end

-- ══════════════════ HWID & EXECUTOR HELPERS ══════════════════
function KeySystem.GetHWID()
    local hwid = nil
    if gethwid then
        pcall(function() hwid = gethwid() end)
    elseif get_hwid then
        pcall(function() hwid = get_hwid() end)
    end
    if not hwid or hwid == "" then
        pcall(function()
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end)
    end
    if not hwid or hwid == "" then
        pcall(function()
            hwid = tostring(LocalPlayer.UserId)
        end)
    end
    return tostring(hwid or "UNKNOWN-HWID")
end

local function fetchUrl(url)
    local result = nil
    local success = pcall(function()
        result = game:HttpGet(url)
    end)
    if success and result and result ~= "" then
        return result
    end

    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if req then
        local s, r = pcall(function()
            return req({Url = url, Method = "GET"})
        end)
        if s and r and r.Body and r.Body ~= "" then
            return r.Body
        end
    end
    return nil
end

local function copyToClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
    elseif toclipboard then
        pcall(toclipboard, text)
    elseif Clipboard and Clipboard.set then
        pcall(Clipboard.set, text)
    end
end

-- ══════════════════ LOCAL SAVE / CACHE ══════════════════
local function saveKeyLocal(fileName, key, hwid)
    if writefile then
        pcall(function()
            writefile(fileName, HttpService:JSONEncode({
                key = key,
                hwid = hwid,
                savedAt = os.time()
            }))
        end)
    end
end

local function readKeyLocal(fileName)
    if isfile and readfile then
        local ok, res = pcall(function()
            if isfile(fileName) then
                return HttpService:JSONDecode(readfile(fileName))
            end
        end)
        if ok and res and typeof(res) == "table" then
            return res
        end
    end
    return nil
end

function KeySystem.DeleteKeyLocal(fileName)
    fileName = fileName or KeySystem.Config.SaveFileName
    if delfile and isfile then
        pcall(function()
            if isfile(fileName) then
                delfile(fileName)
            end
        end)
    elseif writefile then
        pcall(function()
            writefile(fileName, "")
        end)
    end
end

-- เมธอด Logout เรียกใช้ได้จากสคริปต์หลักเพื่อลบเซฟและเปลี่ยนคีย์
function KeySystem.Logout(cfg)
    cfg = cfg or KeySystem.Config
    KeySystem.DeleteKeyLocal(cfg.SaveFileName)
end

-- ══════════════════ ONLINE VERIFICATION & HWID BINDING ══════════════════
function KeySystem.VerifyOnline(inputKey, cfg)
    cfg = cfg or KeySystem.Config
    inputKey = string.gsub(inputKey or "", "^%s*(.-)%s*$", "%1")
    if inputKey == "" then
        return false, "กรุณากรอกคีย์ก่อนกดยืนยัน"
    end

    local myHwid = KeySystem.GetHWID()
    local fileContent = ""
    local fileSha = nil

    local hasToken = (typeof(cfg.GitHubToken) == "string" and cfg.GitHubToken ~= "")
    local req = (syn and syn.request) or request or http_request or (http and http.request)

    -- 1. ตรวจสอบผ่าน GitHub REST API หากมี Token (เพื่อเตรียม SHA สำหรับเขียนทับ)
    if hasToken and req and cfg.GitHubOwner and cfg.GitHubRepo and cfg.GitHubPath then
        local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", cfg.GitHubOwner, cfg.GitHubRepo, cfg.GitHubPath)
        local ok, resp = pcall(function()
            return req({
                Url = apiUrl,
                Method = "GET",
                Headers = {
                    ["Authorization"] = "Bearer " .. cfg.GitHubToken,
                    ["Accept"] = "application/vnd.github.v3+json",
                    ["User-Agent"] = "Universal-KeySystem"
                }
            })
        end)
        if ok and resp and resp.Body then
            local jsonOk, data = pcall(function() return HttpService:JSONDecode(resp.Body) end)
            if jsonOk and data and data.sha and data.content then
                fileSha = data.sha
                fileContent = base64Decode(data.content)
            end
        end
    end

    -- 2. หากไม่มี Token หรือ REST API ดึงไม่สำเร็จ ให้ดึงผ่าน Raw URL โดยตรง
    if fileContent == "" and cfg.KeysUrl and cfg.KeysUrl ~= "" then
        local rawUrl = cfg.KeysUrl .. "?t=" .. tostring(os.time())
        fileContent = fetchUrl(rawUrl) or fetchUrl(cfg.KeysUrl) or ""
    end

    if fileContent == "" then
        return false, "ไม่สามารถเชื่อมต่อระบบคีย์ได้ กรุณาตรวจสอบอินเทอร์เน็ต"
    end

    -- 3. แยกบรรทัดและประมวลผลคีย์
    local lines = {}
    local keyFound = false
    local keyNeedsBind = false
    local targetLineIndex = -1

    for line in string.gmatch(fileContent, "[^\r\n]+") do
        table.insert(lines, line)
    end

    for idx, line in ipairs(lines) do
        local trimmed = string.gsub(line, "^%s*(.-)%s*$", "%1")
        if trimmed ~= "" and not string.find(trimmed, "^#") and not string.find(trimmed, "^%-%-") then
            local colonIdx = string.find(trimmed, ":")
            if colonIdx then
                -- คีย์ถูกผูก HWID ไว้แล้ว (KEY:HWID)
                local k = string.gsub(string.sub(trimmed, 1, colonIdx - 1), "^%s*(.-)%s*$", "%1")
                local h = string.gsub(string.sub(trimmed, colonIdx + 1), "^%s*(.-)%s*$", "%1")
                if k == inputKey then
                    keyFound = true
                    if h == myHwid then
                        -- HWID ตรงกับเครื่องนี้ 100%
                        saveKeyLocal(cfg.SaveFileName, inputKey, myHwid)
                        return true, "คีย์ถูกต้อง! ยินดีต้อนรับเข้าสู่ระบบ"
                    else
                        -- มีเครื่องอื่นผูกคีย์นี้ไปแล้ว
                        return false, "คีย์นี้ถูกใช้งานและล็อคกับเครื่องอื่นไปแล้ว! (HWID Locked)"
                    end
                end
            else
                -- คีย์ยังไม่ได้ผูก HWID (คีย์ว่าง)
                if trimmed == inputKey then
                    keyFound = true
                    keyNeedsBind = true
                    targetLineIndex = idx
                end
            end
        end
    end

    if not keyFound then
        return false, "คีย์ไม่ถูกต้อง หรือไม่มีอยู่ในระบบ"
    end

    -- 4. จัดการคีย์ที่ยังไม่ได้ผูก HWID
    if keyNeedsBind then
        if cfg.StrictHwidOnly and not hasToken then
            return false, "คีย์นี้ยังไม่ได้รับการผูกกับเครื่องของคุณ กรุณาส่ง HWID ให้แอดมินเปิดใช้งาน"
        end

        -- กรณีมี GitHub Token: Commit ผูก HWID ขึ้น GitHub ทันที!
        if hasToken and fileSha and req and cfg.GitHubOwner and cfg.GitHubRepo and cfg.GitHubPath then
            lines[targetLineIndex] = inputKey .. ":" .. myHwid
            local newContent = table.concat(lines, "\n")
            local newBase64 = base64Encode(newContent)

            local putUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", cfg.GitHubOwner, cfg.GitHubRepo, cfg.GitHubPath)
            local putOk, putResp = pcall(function()
                return req({
                    Url = putUrl,
                    Method = "PUT",
                    Headers = {
                        ["Authorization"] = "Bearer " .. cfg.GitHubToken,
                        ["Accept"] = "application/vnd.github.v3+json",
                        ["User-Agent"] = "Universal-KeySystem",
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode({
                        message = "Lock key " .. inputKey .. " to HWID " .. myHwid,
                        content = newBase64,
                        sha = fileSha
                    })
                })
            end)

            if putOk and putResp and (putResp.StatusCode == 200 or putResp.StatusCode == 201) then
                saveKeyLocal(cfg.SaveFileName, inputKey, myHwid)
                return true, "คีย์ถูกต้อง! และได้บันทึกล็อคเครื่องขึ้น GitHub เรียบร้อยแล้ว"
            else
                warn("[KeySystem] เกิดข้อผิดพลาดในการ Auto-Commit ขึ้น GitHub:", putResp and putResp.Body)
            end
        end

        -- บันทึกลงในเครื่อง
        saveKeyLocal(cfg.SaveFileName, inputKey, myHwid)
        return true, "คีย์ถูกต้อง! ยินดีต้อนรับเข้าสู่ระบบ"
    end

    return false, "เกิดข้อผิดพลาดในการตรวจสอบคีย์"
end

-- ══════════════════ KEY SYSTEM UI ══════════════════
function KeySystem.OpenUI(cfg, onSuccessCallback)
    cfg = cfg or KeySystem.Config

    local GuiParent = getSafeGuiParent()

    -- ปิด UI เก่าทิ้งก่อนเปิดใหม่
    local guiName = (cfg.HubName or "App") .. "_KeyGUI"
    pcall(function()
        local old = GuiParent:FindFirstChild(guiName)
        if old then old:Destroy() end
    end)

    local KeyScreen = Create("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        DisplayOrder = 2000,
        Parent = GuiParent,
    })

    local KeyWindow = Create("Frame", {
        Name = "KeyWindow",
        Size = UDim2.new(0, 380, 0, 440),
        Position = UDim2.new(0.5, -190, 0.5, -220),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = KeyScreen,
    })
    RoundCorner(KeyWindow, 12)
    AddStroke(KeyWindow, Theme.Border, 1)

    -- Header
    local KeyHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Parent = KeyWindow,
    })
    RoundCorner(KeyHeader, 12)
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Parent = KeyHeader,
    })

    local KeyDot = Create("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 14, 0.5, -5),
        BackgroundColor3 = Theme.Yellow,
        BorderSizePixel = 0,
        Parent = KeyHeader,
    })
    RoundCorner(KeyDot, 5)

    Create("TextLabel", {
        Text = cfg.HubName or "Key System",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 6),
        Size = UDim2.new(0, 200, 0, 20),
        Parent = KeyHeader,
    })

    Create("TextLabel", {
        Text = cfg.Subtitle or "KEY SYSTEM • 1 KEY PER 1 DEVICE",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 26),
        Size = UDim2.new(0, 250, 0, 16),
        Parent = KeyHeader,
    })

    local KeyCloseBtn = Create("TextButton", {
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.TextMuted,
        BackgroundColor3 = Color3.fromRGB(34, 34, 42),
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        AutoButtonColor = false,
        Parent = KeyHeader,
    })
    RoundCorner(KeyCloseBtn, 6)
    KeyCloseBtn.MouseButton1Click:Connect(function()
        KeyScreen:Destroy()
    end)

    -- Body Container
    local KeyBody = Create("Frame", {
        Size = UDim2.new(1, -28, 1, -62),
        Position = UDim2.new(0, 14, 0, 56),
        BackgroundTransparency = 1,
        Parent = KeyWindow,
    })

    Create("TextLabel", {
        Text = "🔐  ระบบยืนยันตัวตน (Key System)",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.White,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 4),
        Size = UDim2.new(1, 0, 0, 20),
        Parent = KeyBody,
    })

    Create("TextLabel", {
        Text = "คีย์จะถูกล็อคติดเครื่อง 1 คีย์ใช้งานได้แค่เครื่องเดียว",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = KeyBody,
    })

    -- กล่องใส่คีย์ (TextBox)
    local KeyInputCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = KeyBody,
    })
    RoundCorner(KeyInputCard, 8)
    AddStroke(KeyInputCard, Theme.Border, 1)

    local KeyInput = Create("TextBox", {
        PlaceholderText = "กรอกคีย์ของคุณที่นี่...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = "",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.White,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        ClearTextOnFocus = false,
        Parent = KeyInputCard,
    })

    -- การ์ดแสดง HWID ของเครื่อง
    local HwidCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 78),
        Position = UDim2.new(0, 0, 0, 102),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = KeyBody,
    })
    RoundCorner(HwidCard, 8)
    AddStroke(HwidCard, Theme.Border, 1)

    Create("TextLabel", {
        Text = "💻 รหัสเครื่องของคุณ (Hardware ID):",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = HwidCard,
    })

    local myHwidStr = KeySystem.GetHWID()
    local displayHwid = string.sub(myHwidStr, 1, 24) .. (string.len(myHwidStr) > 24 and "..." or "")

    Create("TextLabel", {
        Text = displayHwid,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -120, 0, 18),
        Parent = HwidCard,
    })

    local CopyHwidBtn = Create("TextButton", {
        Text = "📋 คัดลอก HWID",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.White,
        BackgroundColor3 = Theme.CardHover,
        Size = UDim2.new(0, 100, 0, 24),
        Position = UDim2.new(1, -112, 0, 24),
        AutoButtonColor = false,
        Parent = HwidCard,
    })
    RoundCorner(CopyHwidBtn, 6)
    CopyHwidBtn.MouseButton1Click:Connect(function()
        copyToClipboard(myHwidStr)
        CopyHwidBtn.Text = "✓ คัดลอกแล้ว!"
        CopyHwidBtn.BackgroundColor3 = Theme.Green
        task.delay(1.5, function()
            CopyHwidBtn.Text = "📋 คัดลอก HWID"
            CopyHwidBtn.BackgroundColor3 = Theme.CardHover
        end)
    end)

    Create("TextLabel", {
        Text = "หากคีย์ติดล็อคเครื่อง ให้ส่ง HWID นี้ให้แอดมินปลดล็อค",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(120, 120, 130),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 52),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = HwidCard,
    })

    -- ข้อความผลการตรวจสอบ
    local KeyStatusMsg = Create("TextLabel", {
        Text = "พร้อมตรวจสอบคีย์",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 188),
        Size = UDim2.new(1, 0, 0, 22),
        Parent = KeyBody,
    })

    -- ปุ่มยืนยันคีย์ (SUBMIT KEY)
    local SubmitBtn = Create("TextButton", {
        Text = "✓  ยืนยันคีย์ (SUBMIT KEY)",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.White,
        BackgroundColor3 = Theme.Green,
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 0, 218),
        AutoButtonColor = false,
        Parent = KeyBody,
    })
    RoundCorner(SubmitBtn, 8)

    local isChecking = false
    SubmitBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        local input = KeyInput.Text
        if input == "" then
            KeyStatusMsg.Text = "✗ กรุณากรอกคีย์ก่อนกดยืนยัน"
            KeyStatusMsg.TextColor3 = Theme.Red
            return
        end

        isChecking = true
        SubmitBtn.Text = "⏳ กำลังตรวจสอบและล็อค HWID..."
        SubmitBtn.BackgroundColor3 = Theme.CardHover
        KeyStatusMsg.Text = "กำลังติดต่อระบบเพื่อยืนยัน..."
        KeyStatusMsg.TextColor3 = Theme.Yellow
        KeyDot.BackgroundColor3 = Theme.Yellow

        task.spawn(function()
            local success, msg = KeySystem.VerifyOnline(input, cfg)
            isChecking = false

            if success then
                KeyStatusMsg.Text = "✓ " .. msg
                KeyStatusMsg.TextColor3 = Theme.Green
                KeyDot.BackgroundColor3 = Theme.Green
                SubmitBtn.Text = "✓ สำเร็จ! กำลังเปิดโปรแกรม..."
                SubmitBtn.BackgroundColor3 = Theme.Green

                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = cfg.HubName or "Key System",
                        Text = "ยืนยันคีย์สำเร็จ! ยินดีต้อนรับ",
                        Duration = 3
                    })
                end)

                task.wait(0.8)
                KeyScreen:Destroy()

                if onSuccessCallback then
                    task.spawn(onSuccessCallback)
                end
            else
                KeyStatusMsg.Text = "✗ " .. msg
                KeyStatusMsg.TextColor3 = Theme.Red
                KeyDot.BackgroundColor3 = Theme.Red
                SubmitBtn.Text = "✓  ยืนยันคีย์ (SUBMIT KEY)"
                SubmitBtn.BackgroundColor3 = Theme.Green
            end
        end)
    end)

    -- ปุ่มวาง / ล้างข้อความ / รับคีย์
    local PasteRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 270),
        BackgroundTransparency = 1,
        Parent = KeyBody,
    })
    local rowLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        Parent = PasteRow,
    })

    local hasGetKey = (typeof(cfg.GetKeyUrl) == "string" and cfg.GetKeyUrl ~= "")
    local btnWidthScale = hasGetKey and 0.315 or 0.485

    local PasteBtn = Create("TextButton", {
        Text = "📋 วางคีย์",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(btnWidthScale, 0, 1, 0),
        AutoButtonColor = false,
        Parent = PasteRow,
    })
    RoundCorner(PasteBtn, 6)

    local ClearBtn = Create("TextButton", {
        Text = "🗑 ล้าง",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(btnWidthScale, 0, 1, 0),
        AutoButtonColor = false,
        Parent = PasteRow,
    })
    RoundCorner(ClearBtn, 6)

    PasteBtn.MouseButton1Click:Connect(function()
        if getclipboard then
            pcall(function() KeyInput.Text = getclipboard() end)
        end
    end)
    ClearBtn.MouseButton1Click:Connect(function()
        KeyInput.Text = ""
    end)

    if hasGetKey then
        local GetKeyBtn = Create("TextButton", {
            Text = "🔑 รับคีย์",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Theme.Yellow,
            BackgroundColor3 = Theme.Card,
            Size = UDim2.new(btnWidthScale, 0, 1, 0),
            AutoButtonColor = false,
            Parent = PasteRow,
        })
        RoundCorner(GetKeyBtn, 6)
        GetKeyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(cfg.GetKeyUrl)
            GetKeyBtn.Text = "✓ คัดลอกลิงก์แล้ว"
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = cfg.HubName or "Key System",
                    Text = "คัดลอกลิงก์รับคีย์แล้ว นำไปวางในเบราว์เซอร์ได้เลย",
                    Duration = 4
                })
            end)
            task.delay(1.5, function()
                GetKeyBtn.Text = "🔑 รับคีย์"
            end)
        end)
    end

    -- Footer
    Create("TextLabel", {
        Text = (cfg.HubName or "Unique HUB") .. " • GitHub Verified • HWID Locked",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(100, 100, 110),
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 312),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = KeyBody,
    })

    -- ระบบลากหน้าต่าง (Draggable) รองรับทั้งเมาส์และมือถือ
    local dragKey = false
    local dragKeyInput, dragKeyStart, startKeyPos

    KeyHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragKey = true
            dragKeyStart = input.Position
            startKeyPos = KeyWindow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragKey = false
                end
            end)
        end
    end)

    KeyHeader.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragKeyInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragKeyInput and dragKey then
            local delta = input.Position - dragKeyStart
            KeyWindow.Position = UDim2.new(
                startKeyPos.X.Scale, startKeyPos.X.Offset + delta.X,
                startKeyPos.Y.Scale, startKeyPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════ ฟังก์ชันเริ่มต้นทำงาน (START / INIT) ══════════════════
--[[
    วิธีใช้งาน:
    KeySystem.Start(customConfig, function()
        -- ใส่โค้ดหลักของคุณที่นี่ (จะทำงานหลังจากคีย์ผ่านแล้วเท่านั้น)
    end)
--]]
function KeySystem.Start(customConfig, onSuccessCallback)
    local cfg = {}
    for k, v in pairs(KeySystem.Config) do cfg[k] = v end
    if typeof(customConfig) == "table" then
        for k, v in pairs(customConfig) do cfg[k] = v end
    end

    -- 1. ตรวจสอบคีย์ที่บันทึกไว้ในเครื่อง (Auto-Login)
    if cfg.AutoLogin then
        local saved = readKeyLocal(cfg.SaveFileName)
        local myHwid = KeySystem.GetHWID()

        if saved and saved.key and saved.hwid and saved.hwid == myHwid then
            local ok, msg = KeySystem.VerifyOnline(saved.key, cfg)
            if ok then
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = cfg.HubName or "Key System",
                        Text = "เข้าสู่ระบบอัตโนมัติสำเร็จ! ยินดีต้อนรับ",
                        Duration = 3
                    })
                end)
                if onSuccessCallback then
                    task.spawn(onSuccessCallback)
                end
                return
            end
        end
    end

    -- 2. หากไม่มีคีย์เซฟ หรือคีย์เซฟไม่ถูกต้อง ให้เปิด UI ใส่คีย์
    KeySystem.OpenUI(cfg, onSuccessCallback)
end



-- Config
KeySystem.Config = {
    HubName = "(S)Unique HUB",
    Subtitle = "KEY SYSTEM � 1 KEY PER 1 DEVICE",
    KeysUrl = "https://raw.githubusercontent.com/SilasTH2449/Auto-Fishing/refs/heads/main/keys.txt",
    GitHubOwner = "SilasTH2449",
    GitHubRepo  = "Auto-Fishing",
    GitHubPath  = "keys.txt",
    GitHubToken = "", -- ?? ��� Token �ͧ GitHub �������������Ѿഷ����ѵ��ѵ�
    StrictHwidOnly = false,
    SaveFileName = "UniqueHub_SavedKey.json",
    GetKeyUrl = "",
    AutoLogin = true,
}

KeySystem.Start(KeySystem.Config, function()
local _initSuccess, _initErr = pcall(function()

-- ป้องกันการรันซ้ำ ล้าง instance เก่าออกก่อน
if _G.SilasUniqueHubCleanup then
    pcall(_G.SilasUniqueHubCleanup)
end

local scriptRunning = true
local connections = {}

-- ══════════════════ SERVICES & SAFE HELPERS ══════════════════
local Players                = game:GetService("Players")
local RunService             = game:GetService("RunService")
local UserInputService       = game:GetService("UserInputService")
local TweenService           = game:GetService("TweenService")
local HttpService            = game:GetService("HttpService")
local CoreGui                = game:GetService("CoreGui")
local Workspace              = game:GetService("Workspace")
local ReplicatedStorage      = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager    = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        LocalPlayer = Players.PlayerAdded:Wait()
    end)
    if not LocalPlayer then
        LocalPlayer = Players.LocalPlayer
    end
end

local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
local PlayerGui = nil
pcall(function()
    PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 3) or LocalPlayer:FindFirstChild("PlayerGui")
end)

-- Safe task helpers for executor compatibility
local task_spawn = (task and task.spawn) or spawn or function(f) coroutine.wrap(f)() end
local task_wait  = (task and task.wait)  or wait

local function sendNotification(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "(S)Unique HUB",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

-- ══════════════════ ROOT GUI PARENT (SAFE RESOLVER) ══════════════════
-- ทำลาย GUI เก่าก่อน
pcall(function()
    if CoreGui and CoreGui:FindFirstChild("SilasUniqueHub_GUI") then
        CoreGui.SilasUniqueHub_GUI:Destroy()
    end
end)
if PlayerGui then
    pcall(function()
        if PlayerGui:FindFirstChild("SilasUniqueHub_GUI") then
            PlayerGui.SilasUniqueHub_GUI:Destroy()
        end
    end)
end

local GuiParent = nil
pcall(function()
    if gethui then
        GuiParent = gethui()
    end
end)
if not GuiParent then
    pcall(function()
        local test = Instance.new("Folder")
        test.Parent = CoreGui
        test:Destroy()
        GuiParent = CoreGui
    end)
end
if not GuiParent then
    GuiParent = PlayerGui
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "SilasUniqueHub_GUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = GuiParent
end)
if not ScreenGui.Parent and PlayerGui then
    ScreenGui.Parent = PlayerGui
end

-- ══════════════════ LOGO ASSET ══════════════════
local logoAsset = nil
pcall(function()
    if isfile and getcustomasset and isfile("UniqueHub_Logo.jpg") then
        logoAsset = getcustomasset("UniqueHub_Logo.jpg")
    end
end)

-- ══════════════════ THEME (MONOCHROME B&W) ══════════════════
local Theme = {
    BG          = Color3.fromRGB(14, 14, 16),
    Sidebar     = Color3.fromRGB(20, 20, 23),
    Card        = Color3.fromRGB(25, 25, 29),
    CardHover   = Color3.fromRGB(33, 33, 38),
    Border      = Color3.fromRGB(44, 44, 50),
    White       = Color3.fromRGB(250, 250, 250),
    WhiteSoft   = Color3.fromRGB(210, 210, 215),
    Muted       = Color3.fromRGB(140, 140, 145),
    DarkText    = Color3.fromRGB(15, 15, 18),
    TogOff      = Color3.fromRGB(40, 40, 45),
    TogOffKnob  = Color3.fromRGB(130, 130, 135),
    TogOn       = Color3.fromRGB(245, 245, 245),
    TogOnKnob   = Color3.fromRGB(15, 15, 18),
    BadgeBg     = Color3.fromRGB(30, 30, 35),
    Green       = Color3.fromRGB(46, 204, 113),
    Yellow      = Color3.fromRGB(241, 196, 15),
    Red         = Color3.fromRGB(231, 76, 60),
    Gold        = Color3.fromRGB(255, 215, 0),
    Cyan        = Color3.fromRGB(0, 200, 255),
    Purple      = Color3.fromRGB(180, 100, 255),
    Orange      = Color3.fromRGB(255, 160, 60),
}

-- ══════════════════ CONFIGURATION STATE ══════════════════
local Config = {
    -- Aimbot
    aimbotEnabled      = false,
    noBulletDrop       = true,
    aimModeIndex       = 1, -- 1: Smooth Cam, 2: Hard Lock, 3: Mouse Delta
    smoothIndex        = 2, -- 0.25
    wallCheckEnabled   = true,
    targetPartIndex    = 1, -- 1: Head, 2: Neck, 3: HumanoidRootPart
    leadIndex          = 3, -- 1.0
    fovEnabled         = true,
    fovRadius          = 140, -- Slider: 30 - 600 px

    -- Visuals / ESP
    espEnabled         = true,
    teamCheckEnabled   = false,
    boxEspEnabled      = true,
    espHealthBar       = true,
    targetHudEnabled   = true,

    -- Dropped Item ESP
    itemEspEnabled     = false,
    itemCategory       = "ทั้งหมด",
    itemSearch         = {},
    itemEspMaxDist     = 300, -- Slider: 50 - 1500 studs

    -- Movement & Body
    speedEnabled       = false,
    speedValue         = 32, -- Slider: 16 - 120
    infiniteStamina    = false,
    noclipEnabled      = false,
    hitboxExpanded     = false,
    hitboxSize         = 7,  -- Slider: 2 - 20

    -- Combat & Misc
    autoHealEnabled    = false,
    backAlertEnabled   = false,
    instantPickup      = false,

    -- Loot WarZ
    undergroundLoot    = false,
    autoPickupAura     = false,
    lootSearch         = {},

    -- Selected config name
    selectedConfigItem = "Default",
}

local DefaultConfig = {}
for k, v in pairs(Config) do DefaultConfig[k] = v end

-- Options lists
local aimModes = {"Smooth Cam", "Hard Lock", "Mouse Delta"}
local smoothnessLevels = {0.1, 0.25, 0.5, 0.8, 1.0}
local targetParts = {"Head", "Neck", "HumanoidRootPart"}
local targetPartNames = {"Head [หัว]", "Neck [คอ]", "Body [ลำตัว]"}
local leadMultipliers = {0, 0.5, 1.0, 1.5, 2.0}
local itemCategories = {"ทั้งหมด", "อาวุธ", "กระสุน", "ยาและเลือด", "อาหาร/น้ำ", "เกราะ/กระเป๋า", "อื่น ๆ"}

-- State
local stickyTarget = nil
local isMinimized = false
local currentActiveConfigName = "Default"
local savedConfigList = {"Default"}
local CONFIG_SAVE_FILE = "(S)UniqueHub_Configs.json"

-- UI Controls Registry for Syncing
local UIControls = {
    toggles   = {},
    sliders   = {},
    selectors = {},
    inputs    = {}
}

-- ══════════════════ CONFIG MANAGER (MULTI-CONFIG) ══════════════════
local function loadAllConfigsFromDisk()
    if isfile and isfile(CONFIG_SAVE_FILE) and readfile then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_SAVE_FILE))
        end)
        if ok and type(data) == "table" and data.Configs then
            return data
        end
    end
    -- ค่าเริ่มต้น
    return {
        Current = "Default",
        Configs = {
            Default = DefaultConfig
        }
    }
end

local function saveAllConfigsToDisk(masterData)
    if writefile then
        pcall(function()
            writefile(CONFIG_SAVE_FILE, HttpService:JSONEncode(masterData))
        end)
    end
end

local function refreshConfigNamesList()
    local master = loadAllConfigsFromDisk()
    savedConfigList = {}
    for name, _ in pairs(master.Configs) do
        table.insert(savedConfigList, name)
    end
    table.sort(savedConfigList)
    if #savedConfigList == 0 then
        table.insert(savedConfigList, "Default")
    end
end
refreshConfigNamesList()

-- Forward declarations for UI sync
local syncAllUIElements = nil

local function applyConfigData(newConfig)
    for k, v in pairs(newConfig) do
        if Config[k] ~= nil then
            Config[k] = v
        end
    end
    if syncAllUIElements then
        syncAllUIElements()
    end
end

-- ══════════════════ UI BUILDER HELPERS ══════════════════
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function RoundCorner(p, r)
    return Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p})
end

local function Stroke(p, c, t)
    return Create("UIStroke", {Color = c or Theme.Border, Thickness = t or 1, Parent = p})
end

local function Tween(obj, props, dur, style, dir)
    local tw = TweenService:Create(obj,
        TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props)
    tw:Play()
    return tw
end

-- ══════════════════ MAIN WINDOW FRAME (560 x 390) ══════════════════
local MainFrame = Create("Frame", {
    Name             = "MainFrame",
    Size             = UDim2.new(0, 560, 0, 390),
    Position         = UDim2.new(0.5, -280, 0.5, -195),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel  = 0,
    Active           = true,
    Draggable        = true,
    ClipsDescendants = false,
    Visible          = true,
    Parent           = ScreenGui,
})
RoundCorner(MainFrame, 10)
Stroke(MainFrame, Theme.Border, 1)

-- ══════════════════ HEADER BAR ══════════════════
local Header = Create("Frame", {
    Name             = "Header",
    Size             = UDim2.new(1, 0, 0, 54),
    Position         = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
RoundCorner(Header, 10)

Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 10),
    Position         = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel  = 0,
    Parent           = Header,
})

Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    Position         = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel  = 0,
    Parent           = Header,
})

-- กล่องโลโก้
local LogoBox = Create("Frame", {
    Name             = "LogoBox",
    Size             = UDim2.new(0, 38, 0, 38),
    Position         = UDim2.new(0, 12, 0.5, -19),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel  = 0,
    Parent           = Header,
})
RoundCorner(LogoBox, 8)
Stroke(LogoBox, Theme.Border, 1)

if logoAsset then
    Create("ImageLabel", {
        Size                   = UDim2.new(1, -6, 1, -6),
        Position               = UDim2.new(0, 3, 0, 3),
        BackgroundTransparency = 1,
        ScaleType              = Enum.ScaleType.Fit,
        Image                  = logoAsset,
        Parent                 = LogoBox,
    })
else
    Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBlack,
        Text                   = "U",
        TextColor3             = Theme.White,
        TextSize               = 22,
        Parent                 = LogoBox,
    })
end

-- ชื่อ (S)Unique HUB
Create("TextLabel", {
    Name                   = "Title",
    Text                   = "(S)Unique HUB",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 17,
    TextColor3             = Theme.White,
    TextXAlignment         = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position               = UDim2.new(0, 58, 0, 9),
    Size                   = UDim2.new(0, 150, 0, 20),
    Parent                 = Header,
})

Create("TextLabel", {
    Name                   = "Subtitle",
    Text                   = "Silas V1 Engine  •  Monochrome Edition",
    Font                   = Enum.Font.Gotham,
    TextSize               = 11,
    TextColor3             = Theme.Muted,
    TextXAlignment         = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position               = UDim2.new(0, 58, 0, 30),
    Size                   = UDim2.new(0, 220, 0, 16),
    Parent                 = Header,
})

-- ป้ายเวอร์ชัน
local VerBadge = Create("Frame", {
    Size             = UDim2.new(0, 52, 0, 22),
    Position         = UDim2.new(0, 215, 0, 8),
    BackgroundColor3 = Theme.BadgeBg,
    BorderSizePixel  = 0,
    Parent           = Header,
})
RoundCorner(VerBadge, 6)
Stroke(VerBadge, Theme.Border, 1)
Create("TextLabel", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamBold,
    Text                   = "v3.2 S",
    TextColor3             = Theme.WhiteSoft,
    TextSize               = 10,
    Parent                 = VerBadge,
})

-- ป้ายแสดง Config ปัจจุบัน
local ActiveConfigBadge = Create("Frame", {
    Size             = UDim2.new(0, 110, 0, 22),
    Position         = UDim2.new(0, 275, 0, 8),
    BackgroundColor3 = Theme.BadgeBg,
    BorderSizePixel  = 0,
    Parent           = Header,
})
RoundCorner(ActiveConfigBadge, 6)
Stroke(ActiveConfigBadge, Theme.Border, 1)
local ActiveConfigBadgeLabel = Create("TextLabel", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamMedium,
    Text                   = "📁 Default",
    TextColor3             = Theme.WhiteSoft,
    TextSize               = 10,
    Parent                 = ActiveConfigBadge,
})

-- ปุ่มย่อ [X] และปุ่มขีด [-]
local MinKeyBadge = Create("Frame", {
    Size             = UDim2.new(0, 80, 0, 28),
    Position         = UDim2.new(1, -120, 0.5, -14),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel  = 0,
    Parent           = Header,
})
RoundCorner(MinKeyBadge, 6)
Stroke(MinKeyBadge, Theme.Border, 1)
Create("TextLabel", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamMedium,
    Text                   = "กด [X] ย่อ",
    TextColor3             = Theme.WhiteSoft,
    TextSize               = 11,
    Parent                 = MinKeyBadge,
})

local MinBtn = Create("TextButton", {
    Name             = "MinBtn",
    Size             = UDim2.new(0, 28, 0, 28),
    Position         = UDim2.new(1, -34, 0.5, -14),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel  = 0,
    Font             = Enum.Font.GothamBold,
    Text             = "—",
    TextColor3       = Theme.White,
    TextSize         = 14,
    Parent           = Header,
})
RoundCorner(MinBtn, 6)
Stroke(MinBtn, Theme.Border, 1)

-- ══════════════════ MINIMIZED FLOATING BAR ══════════════════
local MiniBar = Create("Frame", {
    Name             = "MiniBar",
    Size             = UDim2.new(0, 170, 0, 36),
    Position         = UDim2.new(0.5, -85, 0.05, 0),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel  = 0,
    Active           = true,
    Draggable        = true,
    Visible          = false,
    Parent           = ScreenGui,
})
RoundCorner(MiniBar, 8)
Stroke(MiniBar, Theme.Border, 1)

if logoAsset then
    local MiniLogo = Create("ImageLabel", {
        Size                   = UDim2.new(0, 24, 0, 24),
        Position               = UDim2.new(0, 6, 0.5, -12),
        BackgroundTransparency = 1,
        ScaleType              = Enum.ScaleType.Fit,
        Image                  = logoAsset,
        Parent                 = MiniBar,
    })
    RoundCorner(MiniLogo, 4)
end

Create("TextLabel", {
    Size                   = UDim2.new(1, -70, 1, 0),
    Position               = UDim2.new(0, 34, 0, 0),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamBold,
    Text                   = "(S)Unique HUB",
    TextColor3             = Theme.White,
    TextSize               = 11,
    TextXAlignment         = Enum.TextXAlignment.Left,
    Parent                 = MiniBar,
})

local MiniExpandBtn = Create("TextButton", {
    Size             = UDim2.new(0, 26, 0, 24),
    Position         = UDim2.new(1, -30, 0.5, -12),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel  = 0,
    Font             = Enum.Font.GothamBold,
    Text             = "▢",
    TextColor3       = Theme.White,
    TextSize         = 11,
    Parent           = MiniBar,
})
RoundCorner(MiniExpandBtn, 4)
Stroke(MiniExpandBtn, Theme.Border, 1)

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Visible = false
        MiniBar.Visible   = true
    else
        MiniBar.Visible   = false
        MainFrame.Visible = true
    end
end

MinBtn.MouseButton1Click:Connect(toggleMinimize)
MiniExpandBtn.MouseButton1Click:Connect(toggleMinimize)

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.X then
        toggleMinimize()
    end
end))

-- ══════════════════ SIDEBAR (ซ้าย) ══════════════════
local Sidebar = Create("Frame", {
    Name             = "Sidebar",
    Size             = UDim2.new(0, 150, 1, -54),
    Position         = UDim2.new(0, 0, 0, 54),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
RoundCorner(Sidebar, 10)

Create("Frame", {
    Size             = UDim2.new(0, 10, 1, 0),
    Position         = UDim2.new(1, -10, 0, 0),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel  = 0,
    Parent           = Sidebar,
})

Create("Frame", {
    Size             = UDim2.new(0, 1, 1, 0),
    Position         = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel  = 0,
    Parent           = Sidebar,
})

local TabContainer = Create("Frame", {
    Name                   = "TabContainer",
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    Parent                 = Sidebar,
})

local SidebarList = Create("UIListLayout", {
    Padding        = UDim.new(0, 4),
    SortOrder      = Enum.SortOrder.LayoutOrder,
    Parent         = TabContainer,
})
Create("UIPadding", {
    PaddingTop   = UDim.new(0, 10),
    PaddingLeft  = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    Parent       = TabContainer,
})

-- ══════════════════ CONTENT AREA (ขวา) ══════════════════
local ContentArea = Create("Frame", {
    Name                   = "ContentArea",
    Size                   = UDim2.new(1, -150, 1, -54),
    Position               = UDim2.new(0, 150, 0, 54),
    BackgroundTransparency = 1,
    ClipsDescendants       = true,
    Parent                 = MainFrame,
})

-- Tab Containers storage
local TabFrames  = {}
local tabButtons = {}
local currentTabName = "Aimbot"

local function createTabContent(name, isDefaultVisible)
    local scroll = Create("ScrollingFrame", {
        Name                   = name .. "Scroll",
        Size                   = UDim2.new(1, 0, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ScrollBarThickness     = 4,
        ScrollBarImageColor3   = Color3.fromRGB(60, 60, 65),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        Visible                = isDefaultVisible or false,
        Parent                 = ContentArea,
    })

    local listLayout = Create("UIListLayout", {
        Padding   = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent    = scroll,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 20),
        PaddingLeft   = UDim.new(0, 14),
        PaddingRight  = UDim.new(0, 18),
        Parent        = scroll,
    })

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)
    end)

    TabFrames[name] = scroll
    return scroll
end

local function switchTab(name)
    currentTabName = name
    for tName, frame in pairs(TabFrames) do
        frame.Visible = (tName == name)
    end
    for tName, data in pairs(tabButtons) do
        local active = (tName == name)
        Tween(data.Btn, {
            BackgroundTransparency = active and 0 or 1,
            BackgroundColor3       = active and Theme.Card or Color3.fromRGB(0,0,0)
        }, 0.15)
        Tween(data.Label, {TextColor3 = active and Theme.White or Theme.Muted}, 0.15)
        Tween(data.Icon,  {TextColor3 = active and Theme.White or Theme.Muted}, 0.15)
        data.Stroke.Transparency = active and 0 or 1
    end
end

local function createTabButton(name, iconText)
    local active = (currentTabName == name)
    local btn = Create("TextButton", {
        Name             = "Tab_" .. name,
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = active and Theme.Card or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = active and 0 or 1,
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
        Text             = "",
        Parent           = TabContainer,
    })
    RoundCorner(btn, 6)
    
    local stroke = Stroke(btn, active and Theme.Border or Color3.fromRGB(0,0,0), 1)
    if not active then stroke.Transparency = 1 end

    local icon = Create("TextLabel", {
        Size                   = UDim2.new(0, 24, 1, 0),
        Position               = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = iconText or "•",
        TextColor3             = active and Theme.White or Theme.Muted,
        TextSize               = 13,
        Parent                 = btn,
    })

    local lbl = Create("TextLabel", {
        Size                   = UDim2.new(1, -36, 1, 0),
        Position               = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamMedium,
        Text                   = name,
        TextColor3             = active and Theme.White or Theme.Muted,
        TextSize               = 12,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = btn,
    })

    tabButtons[name] = {Btn = btn, Label = lbl, Icon = icon, Stroke = stroke}

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- สร้างแท็บตามหมวดหมู่ชัดเจน (Requirement 6)
local aimTab      = createTabContent("Aimbot", true) -- ให้เปิดแท็บแรกทันที
local visualsTab  = createTabContent("Visuals", false)
local movementTab = createTabContent("Movement", false)
local combatTab   = createTabContent("Combat", false)
local lootTab     = createTabContent("WarZ Loot", false)
local configTab   = createTabContent("Configs", false)
local creditsTab  = createTabContent("Credits", false)

createTabButton("Aimbot", "🎯")
createTabButton("Visuals", "👁️")
createTabButton("Movement", "🏃")
createTabButton("Combat", "⚡")
createTabButton("WarZ Loot", "📦")
createTabButton("Configs", "⚙️")
createTabButton("Credits", "ℹ️")

-- ══════════════════ UI CARD BUILDERS ══════════════════
local function createSectionHeader(parent, titleText)
    local frame = Create("Frame", {
        Size                   = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent                 = parent,
    })
    Create("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = string.upper(titleText),
        TextColor3             = Theme.Muted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    return frame
end

local function createToggleCard(parent, titleText, descText, configKey, onToggle)
    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    RoundCorner(card, 8)
    Stroke(card, Theme.Border, 1)

    Create("TextLabel", {
        Size                   = UDim2.new(1, -70, 0, 20),
        Position               = UDim2.new(0, 14, 0, 9),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = titleText,
        TextColor3             = Theme.White,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    Create("TextLabel", {
        Size                   = UDim2.new(1, -70, 0, 16),
        Position               = UDim2.new(0, 14, 0, 29),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.Gotham,
        Text                   = descText,
        TextColor3             = Theme.Muted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    local togBg = Create("Frame", {
        Size             = UDim2.new(0, 42, 0, 22),
        Position         = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = Config[configKey] and Theme.TogOn or Theme.TogOff,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    RoundCorner(togBg, 11)

    local knob = Create("Frame", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = Config[configKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Config[configKey] and Theme.TogOnKnob or Theme.TogOffKnob,
        BorderSizePixel  = 0,
        Parent           = togBg,
    })
    RoundCorner(knob, 8)

    local clickBtn = Create("TextButton", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        Parent                 = togBg,
    })

    local function updateVisualState(newVal)
        Tween(togBg, {BackgroundColor3 = newVal and Theme.TogOn or Theme.TogOff}, 0.18)
        Tween(knob, {
            Position = newVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = newVal and Theme.TogOnKnob or Theme.TogOffKnob
        }, 0.18)
    end

    clickBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        updateVisualState(Config[configKey])
        if onToggle then onToggle(Config[configKey]) end
    end)

    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)

    UIControls.toggles[configKey] = function()
        updateVisualState(Config[configKey])
    end

    return card
end

local function createSliderCard(parent, titleText, descText, minVal, maxVal, configKey, suffix, onValChange)
    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    RoundCorner(card, 8)
    Stroke(card, Theme.Border, 1)

    Create("TextLabel", {
        Size                   = UDim2.new(1, -100, 0, 20),
        Position               = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = titleText,
        TextColor3             = Theme.White,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    local currentVal = Config[configKey] or minVal
    local valLabel = Create("TextLabel", {
        Size                   = UDim2.new(0, 90, 0, 20),
        Position               = UDim2.new(1, -104, 0, 8),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = tostring(currentVal) .. " " .. (suffix or ""),
        TextColor3             = Theme.White,
        TextSize               = 12,
        TextXAlignment         = Enum.TextXAlignment.Right,
        Parent                 = card,
    })

    local track = Create("Frame", {
        Size             = UDim2.new(1, -28, 0, 6),
        Position         = UDim2.new(0, 14, 0, 42),
        BackgroundColor3 = Color3.fromRGB(40, 40, 46),
        BorderSizePixel  = 0,
        Parent           = card,
    })
    RoundCorner(track, 3)

    local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    local fill = Create("Frame", {
        Size             = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme.White,
        BorderSizePixel  = 0,
        Parent           = track,
    })
    RoundCorner(fill, 3)

    local sliderBtn = Create("TextButton", {
        Size                   = UDim2.new(1, 0, 1, 14),
        Position               = UDim2.new(0, 0, 0, -7),
        BackgroundTransparency = 1,
        Text                   = "",
        Parent                 = track,
    })

    local dragging = false
    local function updateFromInput(input)
        local posX = input.Position.X - track.AbsolutePosition.X
        local ratio = math.clamp(posX / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * ratio)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valLabel.Text = tostring(val) .. " " .. (suffix or "")
        Config[configKey] = val
        if onValChange then onValChange(val) end
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)

    UIControls.sliders[configKey] = function()
        local v = Config[configKey] or minVal
        local r = math.clamp((v - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        valLabel.Text = tostring(v) .. " " .. (suffix or "")
    end

    return card
end

local function createSelectorCard(parent, titleText, descText, options, configKey, onSelect)
    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    RoundCorner(card, 8)
    Stroke(card, Theme.Border, 1)

    Create("TextLabel", {
        Size                   = UDim2.new(1, -150, 0, 20),
        Position               = UDim2.new(0, 14, 0, 9),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = titleText,
        TextColor3             = Theme.White,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    Create("TextLabel", {
        Size                   = UDim2.new(1, -150, 0, 16),
        Position               = UDim2.new(0, 14, 0, 29),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.Gotham,
        Text                   = descText,
        TextColor3             = Theme.Muted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    local defaultText = options[1]
    if type(Config[configKey]) == "number" then
        defaultText = options[Config[configKey]] or options[1]
    elseif type(Config[configKey]) == "string" and Config[configKey] ~= "" then
        defaultText = Config[configKey]
    end

    local optionBtn = Create("TextButton", {
        Size             = UDim2.new(0, 130, 0, 30),
        Position         = UDim2.new(1, -144, 0.5, -15),
        BackgroundColor3 = Theme.BadgeBg,
        BorderSizePixel  = 0,
        Font             = Enum.Font.GothamBold,
        Text             = tostring(defaultText),
        TextColor3       = Theme.White,
        TextSize         = 11,
        Parent           = card,
    })
    RoundCorner(optionBtn, 6)
    Stroke(optionBtn, Theme.Border, 1)

    local function cycleOption()
        if type(Config[configKey]) == "number" then
            local idx = (Config[configKey] or 1) + 1
            if idx > #options then idx = 1 end
            Config[configKey] = idx
            optionBtn.Text = tostring(options[idx])
            if onSelect then onSelect(idx) end
        else
            local cur = Config[configKey]
            local curIdx = 1
            for i, opt in ipairs(options) do
                if opt == cur then curIdx = i break end
            end
            local nextIdx = curIdx + 1
            if nextIdx > #options then nextIdx = 1 end
            Config[configKey] = options[nextIdx]
            optionBtn.Text = tostring(options[nextIdx])
            if onSelect then onSelect(options[nextIdx]) end
        end
    end

    optionBtn.MouseButton1Click:Connect(cycleOption)
    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)

    UIControls.selectors[configKey] = function()
        if type(Config[configKey]) == "number" then
            optionBtn.Text = tostring(options[Config[configKey]] or options[1])
        else
            optionBtn.Text = tostring(Config[configKey] or options[1])
        end
    end

    return {
        Card = card,
        SetOptions = function(newOpts)
            options = newOpts
            if type(Config[configKey]) == "number" then
                optionBtn.Text = tostring(options[Config[configKey]] or options[1])
            else
                optionBtn.Text = tostring(Config[configKey] or options[1])
            end
        end
    }
end

local function createMultiSelectCard(parent, titleText, descText, options, configKey)
    if type(Config[configKey]) ~= "table" then
        Config[configKey] = {}
    end

    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel  = 0,
        Parent           = parent,
        ClipsDescendants = true,
    })
    RoundCorner(card, 8)
    Stroke(card, Theme.Border, 1)

    Create("TextLabel", {
        Size                   = UDim2.new(1, -150, 0, 20),
        Position               = UDim2.new(0, 14, 0, 9),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = titleText,
        TextColor3             = Theme.White,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    Create("TextLabel", {
        Size                   = UDim2.new(1, -150, 0, 16),
        Position               = UDim2.new(0, 14, 0, 29),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.Gotham,
        Text                   = descText,
        TextColor3             = Theme.Muted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    local expandBtn = Create("TextButton", {
        Size             = UDim2.new(0, 130, 0, 30),
        Position         = UDim2.new(1, -144, 0, 14),
        BackgroundColor3 = Theme.BadgeBg,
        BorderSizePixel  = 0,
        Font             = Enum.Font.GothamBold,
        Text             = "เลือกไอเทม (+)",
        TextColor3       = Theme.White,
        TextSize         = 11,
        Parent           = card,
    })
    RoundCorner(expandBtn, 6)
    Stroke(expandBtn, Theme.Border, 1)

    local optionsContainer = Create("Frame", {
        Size = UDim2.new(1, -28, 0, 0),
        Position = UDim2.new(0, 14, 0, 58),
        BackgroundTransparency = 1,
        Parent = card,
    })
    local grid = Create("UIGridLayout", {
        CellSize = UDim2.new(0.32, -4, 0, 26),
        CellPadding = UDim2.new(0, 6, 0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsContainer,
    })
    
    local isExpanded = false
    expandBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        if isExpanded then
            local rows = math.ceil(#options / 3)
            local gridHeight = rows * 26 + (rows - 1) * 6
            Tween(card, {Size = UDim2.new(1, 0, 0, 58 + gridHeight + 14)}, 0.2)
            optionsContainer.Size = UDim2.new(1, -28, 0, gridHeight)
            expandBtn.Text = "ปิด (-)"
        else
            Tween(card, {Size = UDim2.new(1, 0, 0, 58)}, 0.2)
            expandBtn.Text = "เลือกไอเทม (+)"
        end
    end)

    for i, opt in ipairs(options) do
        local isSelected = Config[configKey][opt] or false
        local btn = Create("TextButton", {
            BackgroundColor3 = isSelected and Theme.Green or Theme.BadgeBg,
            BorderSizePixel  = 0,
            Font             = Enum.Font.GothamMedium,
            Text             = opt,
            TextColor3       = isSelected and Theme.White or Theme.Muted,
            TextSize         = 11,
            Parent           = optionsContainer,
        })
        RoundCorner(btn, 4)
        btn.MouseButton1Click:Connect(function()
            Config[configKey][opt] = not Config[configKey][opt]
            local state = Config[configKey][opt]
            Tween(btn, {BackgroundColor3 = state and Theme.Green or Theme.BadgeBg}, 0.15)
            Tween(btn, {TextColor3 = state and Theme.White or Theme.Muted}, 0.15)
        end)
    end
    
    UIControls.multiSelectors = UIControls.multiSelectors or {}
    UIControls.multiSelectors[configKey] = function()
        for _, child in ipairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                local opt = child.Text
                local state = Config[configKey][opt]
                child.BackgroundColor3 = state and Theme.Green or Theme.BadgeBg
                child.TextColor3 = state and Theme.White or Theme.Muted
            end
        end
    end
    
    return card
end

local function createActionCard(parent, titleText, descText, btnText, bgColor, textColor, onAction)
    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    RoundCorner(card, 8)
    Stroke(card, Theme.Border, 1)

    Create("TextLabel", {
        Size                   = UDim2.new(1, -125, 0, 20),
        Position               = UDim2.new(0, 14, 0, 9),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = titleText,
        TextColor3             = Theme.White,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    Create("TextLabel", {
        Size                   = UDim2.new(1, -125, 0, 16),
        Position               = UDim2.new(0, 14, 0, 29),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.Gotham,
        Text                   = descText,
        TextColor3             = Theme.Muted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    local actionBtn = Create("TextButton", {
        Size             = UDim2.new(0, 105, 0, 30),
        Position         = UDim2.new(1, -119, 0.5, -15),
        BackgroundColor3 = bgColor or Theme.White,
        BorderSizePixel  = 0,
        Font             = Enum.Font.GothamBold,
        Text             = btnText,
        TextColor3       = textColor or Theme.DarkText,
        TextSize         = 11,
        Parent           = card,
    })
    RoundCorner(actionBtn, 6)

    actionBtn.MouseButton1Click:Connect(function()
        Tween(actionBtn, {BackgroundTransparency = 0.3}, 0.1)
        task_wait(0.1)
        Tween(actionBtn, {BackgroundTransparency = 0}, 0.1)
        if onAction then onAction() end
    end)

    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)

    return card
end

local function createInputCard(parent, titleText, descText, placeholder, defaultText, onTextChange)
    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    RoundCorner(card, 8)
    Stroke(card, Theme.Border, 1)

    Create("TextLabel", {
        Size                   = UDim2.new(1, -160, 0, 20),
        Position               = UDim2.new(0, 14, 0, 11),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamBold,
        Text                   = titleText,
        TextColor3             = Theme.White,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    Create("TextLabel", {
        Size                   = UDim2.new(1, -160, 0, 16),
        Position               = UDim2.new(0, 14, 0, 31),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.Gotham,
        Text                   = descText,
        TextColor3             = Theme.Muted,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = card,
    })

    local inputFrame = Create("Frame", {
        Size             = UDim2.new(0, 140, 0, 32),
        Position         = UDim2.new(1, -154, 0.5, -16),
        BackgroundColor3 = Theme.BadgeBg,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    RoundCorner(inputFrame, 6)
    Stroke(inputFrame, Theme.Border, 1)

    local textBox = Create("TextBox", {
        Size                   = UDim2.new(1, -10, 1, 0),
        Position               = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font                   = Enum.Font.GothamMedium,
        Text                   = defaultText or "",
        PlaceholderText        = placeholder or "พิมพ์ที่นี่...",
        TextColor3             = Theme.White,
        PlaceholderColor3      = Theme.Muted,
        TextSize               = 12,
        ClearTextOnFocus       = false,
        Parent                 = inputFrame,
    })

    textBox.FocusLost:Connect(function()
        if onTextChange then onTextChange(textBox.Text) end
    end)

    card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = Theme.Card}, 0.15) end)

    return {Card = card, TextBox = textBox}
end

-- Sync function: updates all UI cards whenever a config is loaded!
syncAllUIElements = function()
    for _, fn in pairs(UIControls.toggles) do pcall(fn) end
    for _, fn in pairs(UIControls.sliders) do pcall(fn) end
    for _, fn in pairs(UIControls.selectors) do pcall(fn) end
    if UIControls.multiSelectors then
        for _, fn in pairs(UIControls.multiSelectors) do pcall(fn) end
    end
    ActiveConfigBadgeLabel.Text = "📁 " .. tostring(currentActiveConfigName)
end

-- ══════════════════ FLOATING REAL-TIME TARGET HEALTH HUD (Requirement 2) ══════════════════
local TargetHudFrame = Create("Frame", {
    Name             = "TargetHudFrame",
    Size             = UDim2.new(0, 270, 0, 70),
    AnchorPoint      = Vector2.new(0.5, 0),
    Position         = UDim2.new(0.5, 0, 0.74, 0),
    BackgroundColor3 = Color3.fromRGB(16, 16, 20),
    BorderSizePixel  = 0,
    Visible          = false,
    Parent           = ScreenGui,
})
RoundCorner(TargetHudFrame, 8)
Stroke(TargetHudFrame, Theme.Border, 1)

local TargetHudIcon = Create("TextLabel", {
    Size                   = UDim2.new(0, 32, 0, 32),
    Position               = UDim2.new(0, 10, 0, 10),
    BackgroundColor3       = Theme.BadgeBg,
    Font                   = Enum.Font.GothamBold,
    Text                   = "🎯",
    TextColor3             = Theme.White,
    TextSize               = 16,
    Parent                 = TargetHudFrame,
})
RoundCorner(TargetHudIcon, 6)
Stroke(TargetHudIcon, Theme.Border, 1)

local TargetHudName = Create("TextLabel", {
    Size                   = UDim2.new(0, 140, 0, 18),
    Position               = UDim2.new(0, 50, 0, 8),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamBold,
    Text                   = "Enemy: Target",
    TextColor3             = Theme.White,
    TextSize               = 13,
    TextXAlignment         = Enum.TextXAlignment.Left,
    Parent                 = TargetHudFrame,
})

local TargetHudDist = Create("TextLabel", {
    Size                   = UDim2.new(0, 65, 0, 18),
    Position               = UDim2.new(1, -75, 0, 8),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamMedium,
    Text                   = "45m",
    TextColor3             = Theme.Muted,
    TextSize               = 11,
    TextXAlignment         = Enum.TextXAlignment.Right,
    Parent                 = TargetHudFrame,
})

local TargetHudHolding = Create("TextLabel", {
    Size                   = UDim2.new(1, -60, 0, 14),
    Position               = UDim2.new(0, 50, 0, 27),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.Gotham,
    Text                   = "อาวุธ: -",
    TextColor3             = Theme.WhiteSoft,
    TextSize               = 10,
    TextXAlignment         = Enum.TextXAlignment.Left,
    Parent                 = TargetHudFrame,
})

local TargetHealthTrack = Create("Frame", {
    Size             = UDim2.new(1, -20, 0, 8),
    Position         = UDim2.new(0, 10, 1, -18),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel  = 0,
    Parent           = TargetHudFrame,
})
RoundCorner(TargetHealthTrack, 4)

local TargetHealthFill = Create("Frame", {
    Size             = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.Green,
    BorderSizePixel  = 0,
    Parent           = TargetHealthTrack,
})
RoundCorner(TargetHealthFill, 4)

local TargetHealthText = Create("TextLabel", {
    Size                   = UDim2.new(0, 70, 0, 14),
    Position               = UDim2.new(1, -80, 0, 27),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamBold,
    Text                   = "100/100 HP",
    TextColor3             = Theme.Green,
    TextSize               = 10,
    TextXAlignment         = Enum.TextXAlignment.Right,
    Parent                 = TargetHudFrame,
})

-- ══════════════════ FOV CIRCLE (Requirement 4) ══════════════════
local fovFrame = Create("Frame", {
    Name                   = "FOVCircle",
    AnchorPoint            = Vector2.new(0.5, 0.5),
    Position               = UDim2.new(0.5, 0, 0.5, 0),
    Size                   = UDim2.new(0, Config.fovRadius * 2, 0, Config.fovRadius * 2),
    BackgroundTransparency = 1,
    Visible                = false,
    Parent                 = ScreenGui,
})
RoundCorner(fovFrame, 9999)
Stroke(fovFrame, Color3.fromRGB(255, 255, 255), 1.5)

-- ══════════════════ WARNING ALERT (BACK ALERT 20M) ══════════════════
local AlertFrame = Create("Frame", {
    Name             = "AlertFrame",
    AnchorPoint      = Vector2.new(0.5, 0),
    Position         = UDim2.new(0.5, 0, 0.15, 0),
    Size             = UDim2.new(0, 360, 0, 40),
    BackgroundColor3 = Color3.fromRGB(180, 20, 20),
    BorderSizePixel  = 0,
    Visible          = false,
    Parent           = ScreenGui,
})
RoundCorner(AlertFrame, 6)

local AlertText = Create("TextLabel", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font                   = Enum.Font.GothamBold,
    Text                   = "⚠️ WARNING: ENEMY BEHIND YOU!",
    TextColor3             = Theme.White,
    TextSize               = 13,
    Parent                 = AlertFrame,
})

-- ══════════════════ AIMBOT & TARGET CALCULATION ENGINE ══════════════════
local function getRootPart(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") or character.PrimaryPart
end

local function getTargetPart(character)
    if not character then return nil end
    local partName = targetParts[Config.targetPartIndex] or "Head"
    return character:FindFirstChild(partName) or getRootPart(character)
end

local function isEnemy(player)
    if not Config.teamCheckEnabled then return true end
    if player.Team and LocalPlayer and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function isVisible(targetPart)
    if not Config.wallCheckEnabled then return true end
    if not Camera then return true end
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = destination - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local ignoreList = {Camera}
    if LocalPlayer and LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    raycastParams.FilterDescendantsInstances = ignoreList

    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
        return false
    end
    return true
end

local function isValidTarget(player)
    if not player or player == LocalPlayer or not player.Character then return false end
    if not isEnemy(player) then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local targetPart = getTargetPart(player.Character)
    if humanoid and humanoid.Health > 0 and targetPart then
        return true
    end
    return false
end

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local radius = Config.fovRadius
    local shortestDistance = Config.fovEnabled and radius or 999999
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local targetPart = getTargetPart(player.Character)
            if targetPart and isVisible(targetPart) and Camera then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ══════════════════ PLAYER ESP ENGINE (With Health Bar) ══════════════════
local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupChar(char)
        if not char or not scriptRunning then return end
        local rootPart = getRootPart(char) or char:WaitForChild("HumanoidRootPart", 5) or char:WaitForChild("Head", 5)
        if not rootPart then return end

        local highlight = char:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Adornee = char
        highlight.FillColor = Theme.Red
        highlight.FillTransparency = 0.55
        highlight.OutlineColor = Theme.White
        highlight.Enabled = Config.espEnabled and isEnemy(player)
        highlight.Parent = char

        if rootPart:FindFirstChild("ESPBillboard") then rootPart.ESPBillboard:Destroy() end
        local bgui = Instance.new("BillboardGui")
        bgui.Name = "ESPBillboard"
        bgui.Adornee = rootPart
        bgui.Size = UDim2.new(0, 180, 0, 36)
        bgui.StudsOffset = Vector3.new(0, 3.8, 0)
        bgui.AlwaysOnTop = true
        bgui.Enabled = Config.espEnabled and isEnemy(player)
        bgui.Parent = rootPart

        local txt = Instance.new("TextLabel")
        txt.Name = "ESPText"
        txt.Parent = bgui
        txt.Size = UDim2.new(1, 0, 0, 18)
        txt.BackgroundTransparency = 1
        txt.Text = "[ " .. player.Name .. " ]"
        txt.TextColor3 = Theme.White
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        txt.TextSize = 11
        txt.Font = Enum.Font.GothamBold

        -- Mini Health Bar บน ESP (Requirement 2)
        local hpBarBg = Instance.new("Frame")
        hpBarBg.Name = "ESPHpBg"
        hpBarBg.Parent = bgui
        hpBarBg.Size = UDim2.new(0, 80, 0, 4)
        hpBarBg.Position = UDim2.new(0.5, -40, 0, 20)
        hpBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        hpBarBg.BorderSizePixel = 0
        RoundCorner(hpBarBg, 2)

        local hpBarFill = Instance.new("Frame")
        hpBarFill.Name = "ESPHpFill"
        hpBarFill.Parent = hpBarBg
        hpBarFill.Size = UDim2.new(1, 0, 1, 0)
        hpBarFill.BackgroundColor3 = Theme.Green
        hpBarFill.BorderSizePixel = 0
        RoundCorner(hpBarFill, 2)

        if rootPart:FindFirstChild("BoxESPBillboard") then rootPart.BoxESPBillboard:Destroy() end
        local boxGui = Instance.new("BillboardGui")
        boxGui.Name = "BoxESPBillboard"
        boxGui.Adornee = rootPart
        boxGui.Size = UDim2.new(4.5, 0, 6, 0)
        boxGui.StudsOffset = Vector3.new(0, 0.5, 0)
        boxGui.AlwaysOnTop = true
        boxGui.Enabled = Config.espEnabled and Config.boxEspEnabled and isEnemy(player)
        boxGui.Parent = rootPart

        local boxFrame = Instance.new("Frame")
        boxFrame.Parent = boxGui
        boxFrame.Size = UDim2.new(1, 0, 1, 0)
        boxFrame.BackgroundTransparency = 1

        local stroke = Instance.new("UIStroke")
        stroke.Parent = boxFrame
        stroke.Color = Theme.Red
        stroke.Thickness = 1.2
    end

    if player.Character then task_spawn(setupChar, player.Character) end
    table.insert(connections, player.CharacterAdded:Connect(function(char) task_spawn(setupChar, char) end))
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
table.insert(connections, Players.PlayerAdded:Connect(applyESP))

-- ══════════════════ DROPPED ITEM ESP ENGINE (Requirement 3) ══════════════════
local function getLootFolder()
    return Workspace:FindFirstChild("WarzLoot") 
        or Workspace:FindFirstChild("Loot") 
        or Workspace:FindFirstChild("Drops")
end

local function getItemCategory(name)
    local n = string.lower(tostring(name))
    if string.find(n, "bandage") or string.find(n, "med") or string.find(n, "heal") or string.find(n, "pill") or string.find(n, "blood") then
        return "ยาและเลือด"
    elseif string.find(n, "ammo") or string.find(n, "mag") or string.find(n, "stanag") or string.find(n, "bullet") or string.find(n, "box") then
        return "กระสุน"
    elseif string.find(n, "badger") or string.find(n, "rifle") or string.find(n, "gun") or string.find(n, "pistol") or string.find(n, "knife") or string.find(n, "ak") or string.find(n, "m4") or string.find(n, "sniper") or string.find(n, "sig") or string.find(n, "mp5") or string.find(n, "shotgun") or string.find(n, "awp") or string.find(n, "scar") then
        return "อาวุธ"
    elseif string.find(n, "food") or string.find(n, "water") or string.find(n, "soda") or string.find(n, "can") or string.find(n, "eat") or string.find(n, "drink") or string.find(n, "beef") or string.find(n, "apple") then
        return "อาหาร/น้ำ"
    elseif string.find(n, "armor") or string.find(n, "helmet") or string.find(n, "vest") or string.find(n, "bag") or string.find(n, "backpack") then
        return "เกราะ/กระเป๋า"
    end
    return "อื่น ๆ"
end

local function getItemColor(category)
    if category == "อาวุธ" then return Theme.Gold end
    if category == "กระสุน" then return Theme.Cyan end
    if category == "ยาและเลือด" then return Theme.Green end
    if category == "อาหาร/น้ำ" then return Theme.Orange end
    if category == "เกราะ/กระเป๋า" then return Theme.Purple end
    return Theme.WhiteSoft
end

local function isAllowedByFilter(item, searchTable, categoryStr)
    local cat = getItemCategory(item.Name)
    if categoryStr and categoryStr ~= "ทั้งหมด" and cat ~= categoryStr then
        return false
    end
    
    if searchTable and type(searchTable) == "table" then
        if searchTable["ทั้งหมด"] then
            return true
        end
        local hasAnySelection = false
        for k, v in pairs(searchTable) do
            if v then hasAnySelection = true break end
        end
        if hasAnySelection then
            local matched = false
            for k, v in pairs(searchTable) do
                if v and k ~= "ทั้งหมด" then
                    if string.find(string.lower(item.Name), string.lower(k), 1, true) then
                        matched = true
                        break
                    end
                end
            end
            if not matched then return false end
        end
    end
    return true
end

local function updateItemESP()
    local lootFolder = getLootFolder()
    local myRoot = LocalPlayer and LocalPlayer.Character and getRootPart(LocalPlayer.Character)
    if not lootFolder or not myRoot then return end

    for _, item in ipairs(lootFolder:GetChildren()) do
        local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
        if targetPart then
            local dist = (myRoot.Position - targetPart.Position).Magnitude
            local shouldShow = Config.itemEspEnabled and (dist <= Config.itemEspMaxDist) and isAllowedByFilter(item, Config.itemSearch, Config.itemCategory)

            local bgui = targetPart:FindFirstChild("ItemESPBillboard")
            if shouldShow then
                local cat = getItemCategory(item.Name)
                local catColor = getItemColor(cat)

                if not bgui then
                    bgui = Instance.new("BillboardGui")
                    bgui.Name = "ItemESPBillboard"
                    bgui.Adornee = targetPart
                    bgui.Size = UDim2.new(0, 160, 0, 20)
                    bgui.StudsOffset = Vector3.new(0, 1.2, 0)
                    bgui.AlwaysOnTop = true
                    bgui.Parent = targetPart

                    local txt = Instance.new("TextLabel")
                    txt.Name = "ItemESPText"
                    txt.Parent = bgui
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 10
                    txt.TextStrokeTransparency = 0
                    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                end
                bgui.Enabled = true
                local txt = bgui:FindFirstChild("ItemESPText")
                if txt then
                    txt.Text = string.format("[%s] %s [%dm]", cat, item.Name, math.floor(dist))
                    txt.TextColor3 = catColor
                end
            else
                if bgui then bgui.Enabled = false end
            end
        end
    end
end

-- ══════════════════ HEAD HITBOX EXPANSION ══════════════════
local function resetHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                pcall(function()
                    head.Size = Vector3.new(1.2, 1.2, 1.2)
                    head.Transparency = 0
                    head.CanCollide = false
                    local mesh = head:FindFirstChildWhichIsA("SpecialMesh")
                    if mesh then
                        mesh.Scale = Vector3.new(1.2, 1.2, 1.2)
                    end
                end)
            end
        end
    end
end

local function updateHitboxes()
    if not Config.hitboxExpanded or not scriptRunning then return end
    local currentSize = Config.hitboxSize or 7
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isEnemy(player) then
            local head = player.Character:FindFirstChild("Head")
            if head then
                pcall(function()
                    head.Size = Vector3.new(currentSize, currentSize, currentSize)
                    head.Transparency = 0.5
                    head.CanCollide = false
                    head.Massless = true
                    local mesh = head:FindFirstChildWhichIsA("SpecialMesh")
                    if mesh then
                        mesh.Scale = Vector3.new(currentSize, currentSize, currentSize)
                    end
                end)
            end
        end
    end
end

-- ══════════════════ STAMINA & SPEED HOOK (Requirement 5) ══════════════════
local cachedStanceUpvalue = nil
pcall(function()
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts") then
        local clientInput = LocalPlayer.PlayerScripts:FindFirstChild("Client") and LocalPlayer.PlayerScripts.Client:FindFirstChild("input")
        if clientInput and clientInput:FindFirstChild("PlayerStance") then
            local PlayerStance = require(clientInput.PlayerStance)
            local getupv = (debug and debug.getupvalues) or getupvalues
            if getupv then
                for _, fn in pairs(PlayerStance) do
                    if typeof(fn) == "function" then
                        local uvs = getupv(fn)
                        if uvs then
                            for _, uv in pairs(uvs) do
                                if typeof(uv) == "table" and uv.stamina ~= nil then
                                    cachedStanceUpvalue = uv
                                    break
                                end
                            end
                        end
                    end
                    if cachedStanceUpvalue then break end
                end
            end
        end
    end
end)

-- ══════════════════ WARZ LOOTING ENGINE ══════════════════
local PickupLootRemote = nil
local function getPickupRemote()
    if PickupLootRemote and PickupLootRemote.Parent then return PickupLootRemote end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("PickupLoot") then
        PickupLootRemote = remotes.PickupLoot
        return PickupLootRemote
    end
    PickupLootRemote = ReplicatedStorage:FindFirstChild("PickupLoot", true)
    return PickupLootRemote
end

local function getObjectLootUid(obj)
    if not obj then return nil end
    local uid = obj:GetAttribute("LootUid")
    if uid then return uid end
    for _, desc in ipairs(obj:GetDescendants()) do
        uid = desc:GetAttribute("LootUid")
        if uid then return uid end
    end
    return nil
end

local originalItemPositions = {}
local function getItemRealPosition(item)
    if originalItemPositions[item] then return originalItemPositions[item] end
    if item:IsA("Model") then
        local p = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
        return p and p.Position or nil
    elseif item:IsA("BasePart") then
        return item.Position
    end
    return nil
end

local lootSequence = 0
local isLootingBusy = false
local function doPickupLoot(uid, item)
    local remote = getPickupRemote()
    if not uid or not remote or isLootingBusy then return false end
    isLootingBusy = true

    local character = LocalPlayer and LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local oldCFrame = hrp and hrp.CFrame

    if Config.teleportLoot and hrp and item then
        local targetPos = getItemRealPosition(item)
        if targetPos then
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))
            task_wait(0.05)
        end
    end

    lootSequence = lootSequence + 1
    local curSeq = lootSequence
    remote:FireServer(uid, "prep", curSeq)
    task_wait(1.05)
    remote:FireServer(uid, "use", curSeq)
    task_wait(0.1)

    if Config.teleportLoot and hrp and oldCFrame then
        hrp.CFrame = oldCFrame
    end

    isLootingBusy = false
    return true
end

local isUndergroundLooting = false
local function startUndergroundLoot()
    if isUndergroundLooting then return end
    isUndergroundLooting = true
    task_spawn(function()
        while Config.undergroundLoot and scriptRunning do
            local lootFolder = getLootFolder()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if not lootFolder or not hrp or not myHum then
                task_wait(1)
                continue
            end
            
            local targetItem = nil
            local targetDist = math.huge
            local targetRealPos = nil
            
            for _, item in ipairs(lootFolder:GetChildren()) do
                local uid = getObjectLootUid(item)
                if uid and item.Parent and isAllowedByFilter(item, Config.lootSearch, "ทั้งหมด") then
                    local realPos = getItemRealPosition(item)
                    if realPos then
                        local dist = (hrp.Position - realPos).Magnitude
                        if dist < targetDist then
                            targetDist = dist
                            targetItem = item
                            targetRealPos = realPos
                        end
                    end
                end
            end
            
            if targetItem and targetRealPos then
                -- Move underground smoothly at walking speed
                local undergroundTargetPos = targetRealPos - Vector3.new(0, 4, 0)
                local startPos = hrp.Position
                local dist = (startPos - undergroundTargetPos).Magnitude
                
                if dist > 3 then
                    local speed = 20 -- safe running speed
                    local timeToMove = dist / speed
                    hrp.Anchored = true
                    
                    local tweenInfo = TweenInfo.new(timeToMove, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(undergroundTargetPos)})
                    tween:Play()
                    tween.Completed:Wait()
                end
                
                if Config.undergroundLoot and scriptRunning then
                    local uid = getObjectLootUid(targetItem)
                    if uid then
                        -- Tween ขึ้นมาผิวดินแบบสมูท (เพื่อไม่ให้โดนเตะฐานวาร์ป)
                        hrp.Anchored = true
                        local upPos = targetRealPos + Vector3.new(0, 1.5, 0)
                        local upTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
                        local upTween = TweenService:Create(hrp, upTweenInfo, {CFrame = CFrame.new(upPos)})
                        upTween:Play()
                        upTween.Completed:Wait()
                        
                        -- เก็บของขณะที่ Anchored อยู่ ป้องกันเด้งทะลุกำแพง (Physics Explosion)
                        doPickupLoot(uid, targetItem)
                        
                        -- Tween กลับลงดิน
                        local downTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
                        local downTween = TweenService:Create(hrp, downTweenInfo, {CFrame = CFrame.new(undergroundTargetPos)})
                        downTween:Play()
                        downTween.Completed:Wait()
                    end
                end
            else
                task_wait(0.5)
            end
        end
        
        -- ดันตัวขึ้นมาบนดินอย่างสมูทตอนปิด
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = true
            local finalPos = hrp.Position + Vector3.new(0, 5, 0)
            local exitTween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = CFrame.new(finalPos)})
            exitTween:Play()
            exitTween.Completed:Wait()
            hrp.Anchored = false
        end
        isUndergroundLooting = false
    end)
end

-- ══════════════════ CORE RENDER LOOPS ══════════════════

-- 1. Main RenderStepped: Aimbot, FOV, Target Health HUD
table.insert(connections, RunService.RenderStepped:Connect(function()
    if not scriptRunning then return end

    -- อัปเดตวงเล็ง FOV Circle
    if fovFrame then
        fovFrame.Size = UDim2.new(0, Config.fovRadius * 2, 0, Config.fovRadius * 2)
        fovFrame.Visible = Config.fovEnabled
    end

    -- เช็คสถานะตัวละครเรา
    local myHum = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then
        if TargetHudFrame then TargetHudFrame.Visible = false end
        stickyTarget = nil
        return
    end

    -- การเล็งเป้าหมาย Aimbot
    local isHolding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) 
                   or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

    if Config.aimbotEnabled and isHolding then
        if not stickyTarget or not isValidTarget(stickyTarget) or not isVisible(getTargetPart(stickyTarget.Character)) then
            stickyTarget = getClosestPlayerToMouse()
        end

        if stickyTarget and isValidTarget(stickyTarget) and Camera then
            local targetPart = getTargetPart(stickyTarget.Character)
            if targetPart then
                local targetPos = targetPart.Position
                local predictedPos = targetPos

                if not Config.noBulletDrop then
                    local velocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity or Vector3.new(0,0,0)
                    local distance = (targetPos - Camera.CFrame.Position).Magnitude
                    local leadFactor = leadMultipliers[Config.leadIndex] or 1.0
                    local timeToHit = (distance / 2500) * leadFactor
                    predictedPos = targetPos + (velocity * timeToHit)
                end

                local smoothness = smoothnessLevels[Config.smoothIndex] or 0.25
                local mode = aimModes[Config.aimModeIndex] or "Smooth Cam"

                if mode == "Smooth Cam" then
                    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
                elseif mode == "Hard Lock" then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
                elseif mode == "Mouse Delta" then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local deltaX = (screenPos.X - mousePos.X) * smoothness
                        local deltaY = (screenPos.Y - mousePos.Y) * smoothness
                        if mousemoverel then
                            mousemoverel(deltaX, deltaY)
                        else
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, predictedPos), smoothness)
                        end
                    end
                end
            end
        end
    else
        stickyTarget = nil
    end

    -- อัปเดต Target Health HUD (Requirement 2)
    local currentHudTarget = stickyTarget or getClosestPlayerToMouse()
    if Config.targetHudEnabled and currentHudTarget and isValidTarget(currentHudTarget) then
        local tChar = currentHudTarget.Character
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        local tRoot = tChar and getRootPart(tChar)
        local myRoot = LocalPlayer and LocalPlayer.Character and getRootPart(LocalPlayer.Character)

        if tHum and tRoot and myRoot and TargetHudFrame then
            local dist = math.floor((myRoot.Position - tRoot.Position).Magnitude)
            local hp = math.clamp(math.floor(tHum.Health), 0, math.floor(tHum.MaxHealth))
            local maxHp = math.floor(tHum.MaxHealth)
            local ratio = math.clamp(hp / maxHp, 0, 1)

            TargetHudName.Text = "Enemy: " .. currentHudTarget.Name
            TargetHudDist.Text = tostring(dist) .. "m"
            TargetHealthText.Text = string.format("%d/%d HP (%d%%)", hp, maxHp, math.floor(ratio * 100))
            TargetHealthFill.Size = UDim2.new(ratio, 0, 1, 0)

            -- สีเลือดตามเปอร์เซ็นต์
            if ratio > 0.6 then
                TargetHealthFill.BackgroundColor3 = Theme.Green
                TargetHealthText.TextColor3 = Theme.Green
            elseif ratio > 0.25 then
                TargetHealthFill.BackgroundColor3 = Theme.Yellow
                TargetHealthText.TextColor3 = Theme.Yellow
            else
                TargetHealthFill.BackgroundColor3 = Theme.Red
                TargetHealthText.TextColor3 = Theme.Red
            end

            -- ตรวจสอบอาวุธที่ถือ
            local tool = tChar:FindFirstChildOfClass("Tool")
            TargetHudHolding.Text = "อาวุธ: " .. (tool and tool.Name or "มือเปล่า")

            TargetHudFrame.Visible = true
        else
            if TargetHudFrame then TargetHudFrame.Visible = false end
        end
    else
        if TargetHudFrame then TargetHudFrame.Visible = false end
    end

    -- อัปเดต Hitbox
    if Config.hitboxExpanded then
        updateHitboxes()
    end
end))

-- 2. Stepped Loop: Noclip (Requirement 5)
table.insert(connections, RunService.Stepped:Connect(function()
    if Config.noclipEnabled and LocalPlayer and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- 3. Heartbeat Loop: Speed Hack, Stamina
table.insert(connections, RunService.Heartbeat:Connect(function()
    -- Speed Hack (Requirement 5)
    if Config.speedEnabled and LocalPlayer and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.WalkSpeed ~= Config.speedValue then
            hum.WalkSpeed = Config.speedValue
        end
    end

    -- Infinite Stamina (Requirement 5)
    if Config.infiniteStamina and LocalPlayer then
        pcall(function()
            LocalPlayer:SetAttribute("CSGO_SprintPenalty", 0)
            LocalPlayer:SetAttribute("CSGO_Stamina", 75)
            LocalPlayer:SetAttribute("Stamina", 100)
        end)
        if cachedStanceUpvalue and cachedStanceUpvalue.stamina ~= nil then
            cachedStanceUpvalue.stamina = 75
            cachedStanceUpvalue.sprintPenalty = 0
            cachedStanceUpvalue.sprintAirLock = false
        end
    end
end))

-- 4. Background Periodic Loop (ESP, Item ESP, Back Alert, Auto Heal, Loot Magnet)
task_spawn(function()
    local lastAlertTime = 0
    local isHealing = false

    local function sendKeyPress(keyCode)
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task_wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end

    while scriptRunning do
        task_wait(0.12)

        local myChar = LocalPlayer and LocalPlayer.Character
        local myRoot = myChar and getRootPart(myChar)
        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")

        -- Update Player ESP Billboards & Health Bars
        if myRoot and Config.espEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = getRootPart(player.Character)
                    local targetHum  = player.Character:FindFirstChildOfClass("Humanoid")
                    if targetRoot and targetHum then
                        local bgui = targetRoot:FindFirstChild("ESPBillboard")
                        local boxGui = targetRoot:FindFirstChild("BoxESPBillboard")
                        local highlight = player.Character:FindFirstChild("ESPHighlight")
                        local shouldShow = Config.espEnabled and isEnemy(player)

                        if bgui then bgui.Enabled = shouldShow end
                        if boxGui then boxGui.Enabled = shouldShow and Config.boxEspEnabled end
                        if highlight then highlight.Enabled = shouldShow end

                        if shouldShow and bgui then
                            local txt = bgui:FindFirstChild("ESPText")
                            if txt then
                                local dist = math.floor((myRoot.Position - targetRoot.Position).Magnitude)
                                txt.Text = string.format("[ %s ] [ %dm ]", player.Name, dist)
                            end
                            local hpFill = bgui:FindFirstChild("ESPHpFill", true)
                            if hpFill and Config.espHealthBar then
                                local ratio = math.clamp(targetHum.Health / targetHum.MaxHealth, 0, 1)
                                hpFill.Size = UDim2.new(ratio, 0, 1, 0)
                                hpFill.BackgroundColor3 = (ratio > 0.5) and Theme.Green or Theme.Red
                            end
                        end
                    end
                end
            end
        end

        -- Update Dropped Item ESP (Requirement 3)
        if Config.itemEspEnabled then
            pcall(updateItemESP)
        end

        -- Back Alert 20M
        if Config.backAlertEnabled and myRoot and myHum and myHum.Health > 0 then
            local myCFrame = myRoot.CFrame
            local detectedBehind = false
            local enemyName = ""
            local enemyDist = 0

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and isEnemy(player) then
                    local targetRoot = getRootPart(player.Character)
                    if targetRoot then
                        local distance = (targetRoot.Position - myRoot.Position).Magnitude
                        if distance <= 65.6 then -- ~20 เมตร
                            local relativePos = myCFrame:PointToObjectSpace(targetRoot.Position)
                            if relativePos.Z > 0 then
                                detectedBehind = true
                                enemyName = player.Name
                                enemyDist = math.floor(distance / 3.28084)
                                break
                            end
                        end
                    end
                end
            end

            if detectedBehind and AlertFrame then
                AlertText.Text = "⚠️ WARNING: " .. enemyName .. " IS BEHIND YOU! (" .. tostring(enemyDist) .. "m)"
                AlertFrame.Visible = true
                lastAlertTime = tick()
            else
                if tick() - lastAlertTime >= 3 and AlertFrame then
                    AlertFrame.Visible = false
                end
            end
        else
            if AlertFrame then AlertFrame.Visible = false end
        end

        -- Auto Heal
        if Config.autoHealEnabled and not isHealing and myHum and myHum.Health > 0 then
            local healthPercent = (myHum.Health / myHum.MaxHealth) * 100
            if healthPercent <= 85 and healthPercent > 3 then
                isHealing = true
                sendKeyPress(Enum.KeyCode.Three)
                task_wait(0.1)
                sendKeyPress(Enum.KeyCode.Three)
                task_wait(0.1)
                sendKeyPress(Enum.KeyCode.One)
                task_wait(2)
                isHealing = false
            end
        end

        -- Auto Pickup Aura
        if Config.autoPickupAura and myRoot and not isLootingBusy then
            local lootFolder = getLootFolder()
            if lootFolder then
                for _, item in ipairs(lootFolder:GetChildren()) do
                    local uid = getObjectLootUid(item)
                    local realPos = getItemRealPosition(item)
                    -- We can let aura pick up ALL items, or use itemSearch if wanted, 
                    -- let's use the Loot Filter (lootSearch) for Auto Pickup Aura too!
                    if uid and realPos and isAllowedByFilter(item, Config.lootSearch, "ทั้งหมด") then
                        local dist = (myRoot.Position - realPos).Magnitude
                        if dist <= 11 then
                            doPickupLoot(uid, item)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Instant Pickup
table.insert(connections, ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
    if Config.instantPickup then
        if type(fireproximityprompt) == "function" then
            fireproximityprompt(prompt, 1)
        else
            prompt.HoldDuration = 0
        end
    end
end))
table.insert(connections, ProximityPromptService.PromptShown:Connect(function(prompt)
    if Config.instantPickup then prompt.HoldDuration = 0 end
end))

-- ══════════════════ UNLOAD SCRIPT FUNCTION ══════════════════
local function unloadScript()
    scriptRunning = false

    for _, conn in pairs(connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    table.clear(connections)

    resetHitboxes()

    -- คืนค่า WalkSpeed
    if LocalPlayer and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end

    -- ล้าง ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("ESPHighlight")
            if hl then hl:Destroy() end
            local root = getRootPart(player.Character)
            if root then
                if root:FindFirstChild("ESPBillboard") then root.ESPBillboard:Destroy() end
                if root:FindFirstChild("BoxESPBillboard") then root.BoxESPBillboard:Destroy() end
            end
        end
    end

    -- ล้าง Item ESP
    local lootFolder = getLootFolder()
    if lootFolder then
        for _, item in ipairs(lootFolder:GetChildren()) do
            for _, desc in ipairs(item:GetDescendants()) do
                if desc.Name == "ItemESPBillboard" then desc:Destroy() end
            end
        end
    end

    if ScreenGui then ScreenGui:Destroy() end

    sendNotification("(S)Unique HUB", "🔴 ปิดการทำงานสคริปต์เรียบร้อยแล้ว", 3)
    print("[(S)Unique HUB] Script Unloaded Successfully!")
end

_G.SilasUniqueHubCleanup = unloadScript

-- ══════════════════ POPULATE UI CONTROLS ══════════════════

-- [แท็บที่ 1: AIMBOT]
createSectionHeader(aimTab, "ระบบเล็งเป้าอัตโนมัติ (Aimbot)")
createToggleCard(aimTab, "Aimbot (ล็อกเป้า)", "ล็อกเป้าหมายอัตโนมัติเมื่อกดคลิกซ้ายหรือคลิกขวา", "aimbotEnabled")
createToggleCard(aimTab, "No Bullet Drop (กระสุนยิงตรง)", "กระสุนพุ่งตรงเข้าเป้าหมายทันทีโดยไม่ย้อย", "noBulletDrop")
createSelectorCard(aimTab, "Aim Mode (โหมดการเล็ง)", "เลือกวิธีขยับกล้องเล็งเป้า", aimModes, "aimModeIndex")
createSelectorCard(aimTab, "Aim Speed / Smooth", "ระดับความเร็วและความนุ่มนวลของการล็อกเป้า", smoothnessLevels, "smoothIndex")
createToggleCard(aimTab, "Wall Check (เช็คกำแพง)", "ล็อกเฉพาะเป้าหมายที่มองเห็นและไม่อยู่หลังกำแพง", "wallCheckEnabled")
createSelectorCard(aimTab, "Target Part (จุดเล็ง)", "เลือกส่วนของร่างกายที่ต้องการล็อก", targetPartNames, "targetPartIndex")
createSelectorCard(aimTab, "Lead Prediction (นำวิถี)", "คำนวณนำวิถีการเคลื่อนที่ของเป้าหมาย", leadMultipliers, "leadIndex")

createSectionHeader(aimTab, "วงแหวน FOV (FOV Circle Slider)")
createToggleCard(aimTab, "FOV Circle (แสดงวงเล็ง)", "แสดงวงแหวนขอบเขตการล็อกเป้าหมายบนหน้าจอ", "fovEnabled")
createSliderCard(aimTab, "FOV Radius (รัศมีวงเล็ง)", "ปรับขนาดวงแหวน FOV ด้วยหลอดเลื่อน", 30, 600, "fovRadius", "px", function(val)
    if fovFrame then fovFrame.Size = UDim2.new(0, val * 2, 0, val * 2) end
end)

-- [แท็บที่ 2: VISUALS]
createSectionHeader(visualsTab, "มองทะลุผู้เล่น (Player ESP & Health)")
createToggleCard(visualsTab, "Player ESP (มองทะลุคน)", "แสดงชื่อ กรอบ และระยะทางของผู้เล่นทุกคนในแมพ", "espEnabled")
createToggleCard(visualsTab, "Team Check (เฉพาะศัตรู)", "ซ่อน ESP สำหรับเพื่อนร่วมทีม", "teamCheckEnabled")
createToggleCard(visualsTab, "Player Box ESP (กรอบ 3D)", "แสดงกรอบสี่เหลี่ยมรอบตัวผู้เล่น", "boxEspEnabled")
createToggleCard(visualsTab, "ESP Health Bar (หลอดเลือด 3D)", "แสดงหลอดเลือดขนาดเล็กใต้ชื่อของผู้เล่น", "espHealthBar")

createSectionHeader(visualsTab, "หลอดเลือดเป้าหมายเรียลไทม์ (Target Health HUD)")
createToggleCard(visualsTab, "Target Health HUD (หลอดเลือดลอย)", "แสดงหน้าต่างหลอดเลือด ระยะทาง และอาวุธของเป้าหมายแบบเรียลไทม์", "targetHudEnabled")

createSectionHeader(visualsTab, "มองทะลุไอเทมตกพื้น (Dropped Item ESP)")
createToggleCard(visualsTab, "Dropped Item ESP (มองไอเทมตก)", "แสดงป้ายชื่อและระยะทางของไอเทมที่ดรอปอยู่บนพื้น", "itemEspEnabled")
createSelectorCard(visualsTab, "Item Category (หมวดหมู่ไอเทม)", "เลือกกรองหมวดหมู่ไอเทมที่ต้องการแสดง", itemCategories, "itemCategory")
local specificItems = {"ทั้งหมด", "Bandage", "Medkit", "Blood", "Badger", "AK", "M4", "Sniper", "Awp", "Scar", "Stanag", "Ammo", "Armor", "Helmet", "Backpack", "Food", "Water"}
createMultiSelectCard(visualsTab, "ค้นหาชื่อไอเทม (Item Search)", "เลือกไอเทมเฉพาะที่ต้องการมองเห็น (เลือกได้หลายอัน)", specificItems, "itemSearch")
createSliderCard(visualsTab, "Item ESP Max Distance", "ระยะทางไกลสุดที่จะแสดงป้ายไอเทมตกพื้น", 50, 1500, "itemEspMaxDist", "m")

-- [แท็บที่ 3: MOVEMENT]
createSectionHeader(movementTab, "การเคลื่อนที่และความเร็ว (Movement Hacks)")
createToggleCard(movementTab, "วิ่งเร็ว (Speed Walk)", "เร่งความเร็วในการเดินและวิ่งของตัวละคร", "speedEnabled")
createSliderCard(movementTab, "ปรับความเร็ว (Speed Value)", "ปรับระดับความเร็วในการวิ่ง (16 คือปกติ)", 16, 120, "speedValue", "studs/s")
createToggleCard(movementTab, "ไม่เหนื่อย (Infinite Stamina)", "วิ่งได้ตลอดเวลาโดยที่หลอด Stamina ไม่ลด", "infiniteStamina")
createToggleCard(movementTab, "ทะลุกำแพง (Noclip)", "เดินทะลุสิ่งกีดขวาง ประตู และกำแพงได้", "noclipEnabled")

createSectionHeader(movementTab, "ขยายส่วนหัว (Hitbox Expander)")
createToggleCard(movementTab, "Expand Head Hitbox (ขยายหัว)", "ขยายขนาดหัวของศัตรูเพื่อให้ยิงโดนง่ายขึ้น", "hitboxExpanded", function(v)
    if not v then resetHitboxes() end
end)
createSliderCard(movementTab, "Head Size (ขนาดหัว)", "ปรับขนาด Head Hitbox ด้วยหลอดเลื่อน", 2, 20, "hitboxSize", "studs")

-- [แท็บที่ 4: COMBAT & MISC]
createSectionHeader(combatTab, "ช่วยเหลือการต่อสู้ (Combat Helpers)")
createToggleCard(combatTab, "Auto Heal (ปั้มยาออโต้)", "กดสลับยากดปั้มเลือดอัตโนมัติเมื่อเลือดต่ำกว่า 85%", "autoHealEnabled")
createToggleCard(combatTab, "Back Alert 20M (เตือนข้างหลัง)", "แสดงป้ายเตือนสีแดงทันทีเมื่อมีศัตรูอยู่ข้างหลังในระยะ 20 เมตร", "backAlertEnabled")
createToggleCard(combatTab, "Instant Pickup (เก็บของไว)", "เก็บของได้ทันทีไม่ต้องกด E ค้าง", "instantPickup")

-- [แท็บที่ 5: WARZ LOOT]
createSectionHeader(lootTab, "จัดการไอเทม (WarZ / BloxZ)")
createToggleCard(lootTab, "ดูดเก็บรอบตัว (Auto Pickup Aura)", "เก็บไอเทมรอบตัวในระยะ Server (11 studs) อัตโนมัติ", "autoPickupAura")
createToggleCard(lootTab, "ดำดินเก็บของอัตโนมัติ (Auto Underground Loot)", "ดำดินเก็บไอเทมตามที่เลือกไว้แบบเนียนๆ", "undergroundLoot", function(v)
    if v then startUndergroundLoot() end
end)
createMultiSelectCard(lootTab, "เลือกไอเทมที่จะเก็บ (Loot Filter)", "เลือกชนิดไอเทมที่ต้องการดำดินไปเก็บ (เลือกได้หลายอัน)", specificItems, "lootSearch")

-- [แท็บที่ 6: CONFIGS (Requirement 1)]
createSectionHeader(configTab, "ระบบตั้งชื่อและจัดการ Config (Multi-Config Manager)")

local configNameInput = createInputCard(
    configTab,
    "ชื่อ Config (Config Name)",
    "พิมพ์ชื่อการตั้งค่าที่คุณต้องการบันทึก",
    "ตั้งชื่อ Config เช่น PvP, Farm...",
    currentActiveConfigName,
    function(txt)
        if txt and txt ~= "" then currentActiveConfigName = txt end
    end
)

local configSelectorControl = nil
configSelectorControl = createSelectorCard(
    configTab,
    "เลือก Config ที่มีอยู่ (Select Config)",
    "คลิกเพื่อสลับเลือก Config ที่บันทึกไว้ในเครื่อง",
    savedConfigList,
    "selectedConfigItem",
    function(selectedName)
        currentActiveConfigName = selectedName
        if configNameInput and configNameInput.TextBox then
            configNameInput.TextBox.Text = selectedName
        end
    end
)

createActionCard(
    configTab,
    "💾 บันทึก Config ปัจจุบัน (Save Config)",
    "บันทึกค่าที่ตั้งไว้ทั้งหมดลงในชื่อที่ระบุ",
    "บันทึก (Save)",
    Theme.Green,
    Theme.DarkText,
    function()
        local name = configNameInput.TextBox.Text
        if not name or name == "" then name = "Default" end
        name = string.gsub(name, "[^%w_%-]", "")
        if name == "" then name = "Default" end

        local master = loadAllConfigsFromDisk()
        local toSave = {}
        for k, v in pairs(Config) do toSave[k] = v end
        master.Configs[name] = toSave
        master.Current = name
        saveAllConfigsToDisk(master)

        currentActiveConfigName = name
        refreshConfigNamesList()
        configSelectorControl.SetOptions(savedConfigList)
        ActiveConfigBadgeLabel.Text = "📁 " .. name

        sendNotification("Unique HUB Config", "✓ บันทึก Config '" .. name .. "' สำเร็จ!", 3)
    end
)

createActionCard(
    configTab,
    "📁 โหลด Config ที่เลือก (Load Config)",
    "โหลดการตั้งค่าและอัปเดตปุ่มสลับทั้งหมดบนหน้าต่างทันที",
    "โหลด (Load)",
    Theme.White,
    Theme.DarkText,
    function()
        local name = currentActiveConfigName
        local master = loadAllConfigsFromDisk()
        if master.Configs and master.Configs[name] then
            applyConfigData(master.Configs[name])
            sendNotification("Unique HUB Config", "✓ โหลด Config '" .. name .. "' เรียบร้อยแล้ว!", 3)
        else
            sendNotification("Unique HUB Config", "❌ ไม่พบไฟล์ Config ชื่อนี้", 3)
        end
    end
)

createActionCard(
    configTab,
    "🗑️ ลบ Config ที่เลือก (Delete Config)",
    "ลบ Config นี้ออกจากระบบ (ไม่สามารถลบ Default ได้)",
    "ลบ (Delete)",
    Theme.Red,
    Theme.White,
    function()
        local name = currentActiveConfigName
        if name == "Default" then
            sendNotification("Unique HUB Config", "⚠️ ไม่อนุญาตให้ลบ Default Config", 3)
            return
        end
        local master = loadAllConfigsFromDisk()
        if master.Configs and master.Configs[name] then
            master.Configs[name] = nil
            master.Current = "Default"
            saveAllConfigsToDisk(master)

            currentActiveConfigName = "Default"
            if configNameInput and configNameInput.TextBox then
                configNameInput.TextBox.Text = "Default"
            end
            refreshConfigNamesList()
            configSelectorControl.SetOptions(savedConfigList)
            ActiveConfigBadgeLabel.Text = "📁 Default"

            sendNotification("Unique HUB Config", "🗑️ ลบ Config '" .. name .. "' สำเร็จ", 3)
        end
    end
)

createActionCard(
    configTab,
    "🔄 คืนค่าเริ่มต้น (Reset Default)",
    "รีเซ็ตการตั้งค่าทั้งหมดกลับเป็นค่ามาตรฐาน",
    "รีเซ็ต",
    Theme.BadgeBg,
    Theme.WhiteSoft,
    function()
        applyConfigData(DefaultConfig)
        sendNotification("Unique HUB Config", "🔄 คืนค่าเริ่มต้นเรียบร้อยแล้ว", 3)
    end
)

createSectionHeader(configTab, "ปิดการทำงาน (Unload)")
createActionCard(
    configTab,
    "🔴 ปิดการทำงานสคริปต์ (Unload Script)",
    "ลบ UI ทั้งหมดและยกเลิกการเชื่อมต่อ Loop ทั้งหมดอย่างปลอดภัย",
    "ปิดสคริปต์",
    Color3.fromRGB(150, 30, 30),
    Theme.White,
    function()
        unloadScript()
    end
)

-- [แท็บที่ 7: CREDITS & KEYS]
createSectionHeader(creditsTab, "ข้อมูลและปุ่มควบคุม (Information)")
createActionCard(creditsTab, "ปุ่มคีย์ลัดย่อ/ขยาย (Minimize Key)", "กดปุ่ม [X] บนคีย์บอร์ดเพื่อย่อขนาดหน้าต่าง GUI", "คีย์ [X]", Theme.Card, Theme.WhiteSoft, nil)
createActionCard(creditsTab, "พัฒนาโดย (Credits)", "SilasTH2449 Engine • Unique HUB Team Monochrome UI", "Silas HUB", Theme.Card, Theme.WhiteSoft, nil)

-- สลับเปิดแท็บแรก (Aimbot)
switchTab("Aimbot")

-- โหลด Config ล่าสุดอัตโนมัติ (ถ้ามี)
task_spawn(function()
    task_wait(0.2)
    local master = loadAllConfigsFromDisk()
    if master and master.Current and master.Configs[master.Current] then
        currentActiveConfigName = master.Current
        applyConfigData(master.Configs[master.Current])
        if configNameInput and configNameInput.TextBox then
            configNameInput.TextBox.Text = master.Current
        end
    end
end)

sendNotification("(S)Unique HUB", "✓ โหลดระบบและส่วนติดต่อผู้ใช้สำเร็จ!", 3)
print("[(S)Unique HUB] Initialized and Loaded Successfully!")

end) -- end pcall init

if not _initSuccess then
    warn("[(S)Unique HUB] Init Error:", _initErr)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "(S)Unique HUB - Error",
            Text = tostring(_initErr),
            Duration = 10
        })
    end)
end

end)

