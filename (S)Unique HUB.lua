-- ==============================================================================
-- Warz By Unique HUB | Visuals (ESP), Combat & Items
-- Integrated Key System & HWID Lock (GitHub Raw & Auto-Commit)
-- ==============================================================================

-- ══════════════════ CORE SERVICES ══════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local StarterGui       = game:GetService("StarterGui")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        LocalPlayer = Players.LocalPlayer
    end)
end

-- ══════════════════ KEY SYSTEM MODULE ══════════════════
local KeySystem = {
    CurrentKey = nil,
    ExpireTime = nil,
    ExpireStr = nil,
    IsLifetime = false,
    Verified = false,
    _WatchdogRunning = false,
    _WatermarkGui = nil,
}

-- [ ⚙️ CONFIGURATION: ตั้งค่าระบบคีย์ที่นี่ ]
KeySystem.Config = {
    HubName = "Warz By Unique HUB",
    Subtitle = "VISUALS & COMBAT • TIME-LIMITED KEY",

    -- 1. ลิงก์ไฟล์ pskeys.txt ดิบ (Raw) บน GitHub สำหรับตรวจสอบคีย์
    KeysUrl = "https://raw.githubusercontent.com/Un1queHUB/Project-S/refs/heads/main/pskeys.txt",

    -- 2. ข้อมูล GitHub สำหรับระบบ Auto-Commit (ผูก HWID ขึ้น GitHub อัตโนมัติเมื่อใช้คีย์ใหม่)
    GitHubOwner = "Un1queHUB",
    GitHubRepo  = "Project-S",
    GitHubPath  = "pskeys.txt",

    --[[
        [ 🔑 วิธีใส่ GitHub Token เพื่อให้ระบบล็อค HWID ขึ้น GitHub อัตโนมัติ ]
        1. ไปที่ https://github.com/settings/tokens?type=beta (Fine-grained personal access tokens)
        2. กด "Generate new token" ตั้งชื่อ เช่น "KeySystemToken"
        3. Repository access: เลือก "Only select repositories" แล้วเลือก Repo "Project-S"
        4. Permissions -> Repository permissions -> Contents: เลือก "Read and write"
        5. กด Generate แล้วนำ Token (เช่น github_pat_xxxx) มาวางในช่องด้านล่าง
    --]]
    GitHubToken = "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",

    -- หากเป็น true: คีย์บน GitHub จะต้องมี :HWID เท่านั้นถึงจะเข้าได้ (ป้องกันคนเอาคีย์ว่างไปแชร์กัน)
    -- หากเป็น false: อนุญาตให้คีย์ที่ยังไม่มี :HWID ถูกผูกกับเครื่องแรกที่นำไปใช้
    StrictHwidOnly = true,

    -- 3. ชื่อไฟล์เซฟคีย์ในเครื่องผู้ใช้ (ระบบจำคีย์ / Auto-Login)
    SaveFileName = "WarzUniqueHUB_SavedKey.json",

    -- 4. ลิงก์สำหรับรับคีย์ หรือ ลิงก์ Discord (หากมีจะแสดงปุ่ม "🔑 รับคีย์" บน UI / หากไม่มีให้ใส่ "")
    GetKeyUrl = "",

    -- 5. เปิดใช้งานระบบล็อกอินอัตโนมัติ (จำคีย์ไม่ต้องพิมพ์ซ้ำ)
    AutoLogin = true,

    -- 6. ตรวจสอบคีย์ในพื้นหลังทุกๆ N วินาที (ปรับเป็น 10-15 วินาที เพื่อให้คีย์เทส 1 นาทีตัดการทำงานได้อย่างแม่นยำ)
    WatchdogInterval = 10,
}

-- ══════════════════ THEME / UI COLORS ══════════════════
local KeyTheme = {
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
    Accent      = Color3.fromRGB(0, 170, 255),
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
        Color = color or KeyTheme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

local function getSafeGuiParent()
    local parent = nil
    pcall(function()
        if gethui then
            parent = gethui()
        elseif CoreGui then
            parent = CoreGui
        end
    end)
    if not parent and LocalPlayer then
        parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    return parent
end

-- ══════════════════ BASE64 ENGINE ══════════════════
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64lookup = {}
for i = 1, #b64chars do
    b64lookup[b64chars:sub(i, i)] = i - 1
end

local function base64Encode(str)
    if crypt and crypt.base64encode then
        local ok, res = pcall(crypt.base64encode, str)
        if ok and res then return res end
    elseif crypt and crypt.base64_encode then
        local ok, res = pcall(crypt.base64_encode, str)
        if ok and res then return res end
    elseif syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.encode then
        local ok, res = pcall(syn.crypt.base64.encode, str)
        if ok and res then return res end
    elseif base64_encode then
        local ok, res = pcall(base64_encode, str)
        if ok and res then return res end
    end

    local bytes = {str:byte(1, #str)}
    local result = {}
    local pad = 3 - (#bytes % 3)
    if pad == 3 then pad = 0 end
    for i = 1, pad do table.insert(bytes, 0) end
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
    if crypt and crypt.base64decode then
        local ok, res = pcall(crypt.base64decode, data)
        if ok and res then return res end
    elseif crypt and crypt.base64_decode then
        local ok, res = pcall(crypt.base64_decode, data)
        if ok and res then return res end
    elseif syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
        local ok, res = pcall(syn.crypt.base64.decode, data)
        if ok and res then return res end
    elseif base64_decode then
        local ok, res = pcall(base64_decode, data)
        if ok and res then return res end
    end

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

-- ══════════════════ TIME & DATE PROTECTION ENGINE ══════════════════
-- ตรวจสอบเวลาจริงผ่าน Roblox Server เพื่อป้องกันการโกงเวลาเครื่อง Windows
local function getServerNow()
    local t = nil
    pcall(function()
        if workspace and workspace.GetServerTimeNow then
            t = workspace:GetServerTimeNow()
        end
    end)
    if not t or t <= 0 then
        pcall(function()
            t = os.time()
        end)
    end
    return math.floor(t or 0)
end

-- แปลงเวลา Timestamp เป็นฟอร์แมต YYYY-MM-DD-HH:MM (UTC มาตรฐานตรงกันทั่วโลก)
local function formatTimestamp(ts)
    local d = nil
    pcall(function()
        d = os.date("!*t", math.floor(ts))
    end)
    if d and d.year and d.month and d.day and d.hour and d.min then
        return string.format("%04d-%02d-%02d-%02d:%02d", d.year, d.month, d.day, d.hour, d.min)
    end

    -- ระบบคำนวณปฏิทิน UTC สำรองหาก os.date โดนจำกัดโดย Executor
    local totalSec = math.max(0, math.floor(ts))
    local totalMin = math.floor(totalSec / 60)
    local min = totalMin % 60
    local totalHour = math.floor(totalMin / 60)
    local hour = totalHour % 24
    local totalDays = math.floor(totalHour / 24)

    local y = 1970
    while true do
        local isLeap = (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
        local daysInYear = isLeap and 366 or 365
        if totalDays >= daysInYear then
            totalDays = totalDays - daysInYear
            y = y + 1
        else
            break
        end
    end
    local isLeap = (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
    local monthDays = {31, isLeap and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local m = 1
    for mi = 1, 12 do
        if totalDays >= monthDays[mi] then
            totalDays = totalDays - monthDays[mi]
            m = m + 1
        else
            break
        end
    end
    local day = totalDays + 1
    return string.format("%04d-%02d-%02d-%02d:%02d", y, m, day, hour, min)
end

-- แปลงวันหมดอายุ YYYY-MM-DD-HH:MM กลับเป็น Unix Timestamp (ครอบคลุมถึงวินาทีที่ :59 ของนาทีนั้น)
local function parseDateToTimestamp(dateStr)
    if not dateStr or dateStr == "" or string.upper(dateStr) == "LIFETIME" then return nil end
    local y, m, d, h, min = string.match(dateStr, "^(%d%d%d%d)%-(%d%d)%-(%d%d)[%-%s](%d%d):(%d%d)")
    if not (y and m and d and h and min) then return nil end
    y, m, d, h, min = tonumber(y), tonumber(m), tonumber(d), tonumber(h), tonumber(min)
    if not (y and m and d and h and min) then return nil end

    local totalDays = 0
    for yr = 1970, y - 1 do
        local isLeap = (yr % 4 == 0 and yr % 100 ~= 0) or (yr % 400 == 0)
        totalDays = totalDays + (isLeap and 366 or 365)
    end
    local isLeap = (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
    local monthDays = {31, isLeap and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    for mi = 1, m - 1 do
        totalDays = totalDays + monthDays[mi]
    end
    totalDays = totalDays + (d - 1)

    -- เพิ่ม +59 วินาที เพื่อให้มีอายุใช้งานจนสิ้นสุดนาทีนั้นอย่างเต็มที่
    return (totalDays * 86400) + (h * 3600) + (min * 60) + 59
end

-- ดึงระยะเวลาเป็นวินาทีตามแท็ก (1M = 60วิ, 1D = 86400วิ, 7D = 604800วิ, 30D = 2592000วิ, LIFETIME = -1)
local function getTagDuration(tag)
    if not tag or tag == "" then return -1 end
    tag = string.upper(string.gsub(tag, "%s+", ""))
    if tag == "LIFETIME" or tag == "PERM" or tag == "PERMANENT" then
        return -1
    elseif tag == "1M" then
        return 60
    elseif tag == "1D" then
        return 86400
    elseif tag == "7D" then
        return 604800
    elseif tag == "30D" then
        return 2592000
    end

    local num, unit = string.match(tag, "^(%d+)([MDHS])$")
    if num and unit then
        num = tonumber(num)
        if unit == "M" then return num * 60 end
        if unit == "H" then return num * 3600 end
        if unit == "D" then return num * 86400 end
        if unit == "S" then return num end
    end
    return -1
end

-- ฟอร์แมตเวลาที่เหลือเป็นข้อความภาษาไทย (วัน, ชั่วโมง, นาที, วินาที)
local function formatTimeRemaining(seconds)
    if not seconds or seconds < 0 then
        return "หมดอายุแล้ว"
    end
    if seconds == math.huge or seconds >= 10^9 then
        return "ถาวร (LIFETIME)"
    end

    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    local parts = {}
    if days > 0 then
        table.insert(parts, string.format("%d วัน", days))
    end
    if hours > 0 or days > 0 then
        table.insert(parts, string.format("%d ชั่วโมง", hours))
    end
    if mins > 0 or hours > 0 or days > 0 then
        table.insert(parts, string.format("%d นาที", mins))
    end
    table.insert(parts, string.format("%d วินาที", secs))

    if #parts == 0 then
        return "0 วินาที"
    end
    return table.concat(parts, " ")
end

-- ฟอร์แมตเวลาแบบย่อสำหรับ Watermark HUD
local function formatTimeCompact(seconds)
    if not seconds or seconds < 0 then return "หมดอายุแล้ว" end
    if seconds == math.huge or seconds >= 10^9 then return "♾️ ถาวร (Lifetime)" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    if days > 0 then
        return string.format("%d วัน %02d:%02d:%02d", days, hours, mins, secs)
    else
        return string.format("%02d:%02d:%02d", hours, mins, secs)
    end
end

-- ตรวจสอบและแยกข้อมูลบรรทัดคีย์บน GitHub (Unbound, Bound-Timed, Bound-Lifetime, Legacy)
local function parseKeyLine(rawLine)
    local line = string.gsub(rawLine or "", "^%s*(.-)%s*$", "%1")
    if line == "" or string.sub(line, 1, 1) == "#" or string.sub(line, 1, 2) == "--" then
        return nil
    end

    -- 1. คีย์ที่ยังไม่ผูกเครื่อง มีแท็กเวลา (KEY::TAG เช่น PS-KEY-xxxx::1M, PS-KEY-xxxx::LIFETIME)
    local k1, tag1 = string.match(line, "^([^:]+)::([^:]+)$")
    if k1 and tag1 then
        return {
            status = "unbound",
            key = string.gsub(k1, "^%s*(.-)%s*$", "%1"),
            tag = string.gsub(tag1, "^%s*(.-)%s*$", "%1"),
            isLifetime = (string.upper(tag1) == "LIFETIME"),
            raw = line,
        }
    end

    -- 2. คีย์ที่ผูก HWID และมีวันเวลาหมดอายุ (KEY:HWID:YYYY-MM-DD-HH:MM)
    local k2, h2, exp2 = string.match(line, "^([^:]+):([^:]+):(%d%d%d%d%-%d%d%-%d%d[%-%s]%d%d:%d%d.*)$")
    if k2 and h2 and exp2 then
        return {
            status = "bound",
            key = string.gsub(k2, "^%s*(.-)%s*$", "%1"),
            hwid = string.gsub(h2, "^%s*(.-)%s*$", "%1"),
            expireStr = exp2,
            isLifetime = false,
            raw = line,
        }
    end

    -- 3. คีย์ที่ผูก HWID แบบถาวร (KEY:HWID:LIFETIME)
    local k3, h3, tag3 = string.match(line, "^([^:]+):([^:]+):([%a%d]+)$")
    if k3 and h3 and tag3 and string.upper(tag3) == "LIFETIME" then
        return {
            status = "bound",
            key = string.gsub(k3, "^%s*(.-)%s*$", "%1"),
            hwid = string.gsub(h3, "^%s*(.-)%s*$", "%1"),
            expireStr = "LIFETIME",
            isLifetime = true,
            raw = line,
        }
    end

    -- 4. คีย์เดิมที่ผูก HWID แบบไม่มีวันหมดอายุ (KEY:HWID -> ถาวร)
    local k4, h4 = string.match(line, "^([^:]+):([^:]+)$")
    if k4 and h4 then
        return {
            status = "bound",
            key = string.gsub(k4, "^%s*(.-)%s*$", "%1"),
            hwid = string.gsub(h4, "^%s*(.-)%s*$", "%1"),
            expireStr = "LIFETIME",
            isLifetime = true,
            raw = line,
        }
    end

    -- 5. คีย์ว่างเปล่าแบบไม่มีแท็ก (KEY -> ถาวร)
    if not string.find(line, ":") then
        return {
            status = "unbound",
            key = line,
            tag = "LIFETIME",
            isLifetime = true,
            raw = line,
        }
    end

    return nil
end

-- ══════════════════ HWID & EXECUTOR HELPERS ══════════════════
function KeySystem.GetHWID()
    local hwid = nil
    pcall(function()
        if gethwid then
            hwid = gethwid()
        elseif get_hwid then
            hwid = get_hwid()
        end
    end)
    if not hwid or hwid == "" then
        pcall(function()
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end)
    end
    if not hwid or hwid == "" then
        pcall(function()
            local lp = Players.LocalPlayer
            if lp then hwid = tostring(lp.UserId) end
        end)
    end
    return tostring(hwid or "UNKNOWN-DEVICE-ID")
end

local function compareHWID(savedHwid, currentHwid)
    if not savedHwid or not currentHwid then return false end
    local s = string.lower(string.gsub(tostring(savedHwid), "%s+", ""))
    local c = string.lower(string.gsub(tostring(currentHwid), "%s+", ""))
    if s == c then return true end

    local sClean = s:gsub("[{}]", "")
    local cClean = c:gsub("[{}]", "")
    if sClean == cClean then return true end

    local hexC = ""
    for i = 1, #c do
        hexC = hexC .. string.format("%02x", string.byte(c, i))
    end
    if s == hexC then return true end

    local hexS = ""
    for i = 1, #s do
        hexS = hexS .. string.format("%02x", string.byte(s, i))
    end
    if hexS == c then return true end

    return false
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

function KeySystem.CopyHWID()
    local hwid = KeySystem.GetHWID()
    copyToClipboard(hwid)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = KeySystem.Config.HubName or "Key System",
            Text = "คัดลอก HWID เรียบร้อยแล้ว! นำไปส่งให้แอดมินได้เลย",
            Duration = 3
        })
    end)
    return hwid
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

-- ══════════════════ LOCAL SAVE / CACHE ══════════════════
local function saveKeyLocal(fileName, key, hwid, expireTimestamp, expireStr)
    if writefile then
        pcall(function()
            writefile(fileName, HttpService:JSONEncode({
                key = key,
                hwid = hwid,
                expireTimestamp = expireTimestamp,
                expireStr = expireStr,
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

function KeySystem.Logout()
    KeySystem.DeleteKeyLocal(KeySystem.Config.SaveFileName)
    KeySystem.CurrentKey = nil
    KeySystem.ExpireTime = nil
    KeySystem.ExpireStr = nil
    KeySystem.IsLifetime = false
    KeySystem.Verified = false
    KeySystem._WatchdogRunning = false
    if KeySystem._WatermarkGui then
        pcall(function() KeySystem._WatermarkGui:Destroy() end)
        KeySystem._WatermarkGui = nil
    end
end

-- ══════════════════ ONLINE VERIFICATION & HWID BINDING ══════════════════
function KeySystem.VerifyOnline(inputKey, cfg)
    cfg = cfg or KeySystem.Config
    inputKey = string.gsub(inputKey or "", "^%s*(.-)%s*$", "%1")
    if inputKey == "" then
        return false, "กรุณากรอกคีย์ก่อนกดยืนยัน"
    end

    -- สกัดรหัสคีย์หลัก (รองรับกรณีผู้ใช้ก็อปปี้มาทั้งบรรทัดที่มี ::TAG หรือ :HWID)
    local cleanKey = string.gsub(inputKey, "::.*$", "")
    cleanKey = string.gsub(cleanKey, ":.*$", "")
    cleanKey = string.gsub(cleanKey, "^%s*(.-)%s*$", "%1")

    local myHwid = KeySystem.GetHWID()
    local fileContent = ""
    local fileSha = nil

    local hasToken = (typeof(cfg.GitHubToken) == "string" and cfg.GitHubToken ~= "")
    local req = (syn and syn.request) or request or http_request or (http and http.request)

    -- 1. ตรวจสอบผ่าน GitHub REST API หากมี Token (เพื่อดึง SHA ล่าสุดสำหรับ Auto-Commit)
    if hasToken and req and cfg.GitHubOwner and cfg.GitHubRepo and cfg.GitHubPath then
        local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", cfg.GitHubOwner, cfg.GitHubRepo, cfg.GitHubPath)
        local ok, resp = pcall(function()
            return req({
                Url = apiUrl,
                Method = "GET",
                Headers = {
                    ["Authorization"] = "Bearer " .. cfg.GitHubToken,
                    ["Accept"] = "application/vnd.github.v3+json",
                    ["User-Agent"] = "Warz-UniqueHUB-KeySystem"
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

    -- 2. หากไม่มี Token หรือ REST API ดึงไม่สำเร็จ ให้ดึงผ่าน Raw URL โดยตรง (พร้อม Anti-Cache timestamp)
    if fileContent == "" and cfg.KeysUrl and cfg.KeysUrl ~= "" then
        local rawUrl = cfg.KeysUrl .. "?t=" .. tostring(os.time())
        fileContent = fetchUrl(rawUrl) or fetchUrl(cfg.KeysUrl) or ""
    end

    if fileContent == "" then
        return false, "ไม่สามารถเชื่อมต่อ GitHub ได้ กรุณาตรวจสอบอินเทอร์เน็ต"
    end

    -- 3. แยกบรรทัดและประมวลผลค้นหาคีย์
    local lines = {}
    local matchedParsed = nil
    local targetLineIndex = -1

    for line in string.gmatch(fileContent, "[^\r\n]+") do
        table.insert(lines, line)
    end

    for idx, line in ipairs(lines) do
        local parsed = parseKeyLine(line)
        if parsed then
            if parsed.key == cleanKey or parsed.key == inputKey then
                matchedParsed = parsed
                targetLineIndex = idx
                break
            end
        end
    end

    if not matchedParsed then
        return false, "คีย์ไม่ถูกต้อง หรือไม่มีอยู่ในระบบ GitHub"
    end

    -- 4. จัดการคีย์ที่ถูกผูก HWID ไว้แล้ว (BOUND KEY)
    if matchedParsed.status == "bound" then
        -- ตรวจสอบ HWID ว่าตรงกับเครื่องนี้หรือไม่
        if not compareHWID(matchedParsed.hwid, myHwid) then
            return false, "คีย์นี้ถูกใช้งานและล็อคกับเครื่องอื่นไปแล้ว! (HWID Locked)"
        end

        -- กรณีคีย์ถาวร (LIFETIME)
        if matchedParsed.isLifetime then
            KeySystem.CurrentKey = matchedParsed.key
            KeySystem.ExpireTime = nil
            KeySystem.ExpireStr = "LIFETIME"
            KeySystem.IsLifetime = true
            KeySystem.Verified = true
            saveKeyLocal(cfg.SaveFileName, matchedParsed.key, myHwid, nil, "LIFETIME")
            return true, "คีย์ถูกต้อง! สิทธิ์ใช้งานแบบถาวร (Lifetime)", math.huge
        else
            -- กรณีคีย์มีกำหนดเวลาหมดอายุ
            local expTs = parseDateToTimestamp(matchedParsed.expireStr)
            local now = getServerNow()

            if not expTs or now >= expTs then
                -- คีย์หมดอายุแล้ว! ลบเซฟทิ้งทันที
                KeySystem.DeleteKeyLocal(cfg.SaveFileName)
                KeySystem.Verified = false
                return false, "คีย์ของคุณหมดอายุการใช้งานแล้ว! (หมดอายุเมื่อ: " .. tostring(matchedParsed.expireStr) .. ")"
            else
                -- คีย์ยังไม่หมดอายุ ใช้งานได้ปกติ
                local remaining = expTs - now
                KeySystem.CurrentKey = matchedParsed.key
                KeySystem.ExpireTime = expTs
                KeySystem.ExpireStr = matchedParsed.expireStr
                KeySystem.IsLifetime = false
                KeySystem.Verified = true
                saveKeyLocal(cfg.SaveFileName, matchedParsed.key, myHwid, expTs, matchedParsed.expireStr)
                return true, "คีย์ถูกต้อง! ยินดีต้อนรับเข้าสู่ระบบ (เหลือเวลา: " .. formatTimeRemaining(remaining) .. ")", remaining
            end
        end
    end

    -- 5. จัดการคีย์ที่ยังไม่ได้ผูก HWID (FIRST-USE ACTIVATION)
    if matchedParsed.status == "unbound" then
        if cfg.StrictHwidOnly then
            return false, "คีย์นี้ยังไม่ได้รับการล็อคเครื่อง กรุณาส่ง HWID ให้แอดมินเปิดใช้งาน"
        end

        local duration = getTagDuration(matchedParsed.tag)
        local now = getServerNow()
        local expireTimestamp = nil
        local expireDateStr = nil
        local newLine = nil

        if duration and duration > 0 then
            expireTimestamp = now + duration
            expireDateStr = formatTimestamp(expireTimestamp)
            newLine = matchedParsed.key .. ":" .. myHwid .. ":" .. expireDateStr
        else
            expireDateStr = "LIFETIME"
            newLine = matchedParsed.key .. ":" .. myHwid .. ":LIFETIME"
        end

        -- กรณีมี GitHub Token: Auto-Commit ผูก HWID และเวลาหมดอายุขึ้น GitHub ทันที!
        if hasToken and req and cfg.GitHubOwner and cfg.GitHubRepo and cfg.GitHubPath then
            -- หากยังไม่มี fileSha ให้ดึง SHA ล่าสุดจาก GitHub REST API ก่อน
            if not fileSha then
                local getUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", cfg.GitHubOwner, cfg.GitHubRepo, cfg.GitHubPath)
                local gOk, gResp = pcall(function()
                    return req({
                        Url = getUrl,
                        Method = "GET",
                        Headers = {
                            ["Authorization"] = "Bearer " .. cfg.GitHubToken,
                            ["Accept"] = "application/vnd.github.v3+json",
                            ["User-Agent"] = "Warz-UniqueHUB-KeySystem"
                        }
                    })
                end)
                if gOk and gResp and gResp.Body then
                    local jOk, d = pcall(function() return HttpService:JSONDecode(gResp.Body) end)
                    if jOk and d and d.sha then
                        fileSha = d.sha
                        if d.content then
                            local fresh = base64Decode(d.content)
                            if fresh and fresh ~= "" then
                                local freshLines = {}
                                for fl in string.gmatch(fresh, "[^\r\n]+") do table.insert(freshLines, fl) end
                                for fIdx, fl in ipairs(freshLines) do
                                    local p = parseKeyLine(fl)
                                    if p and (p.key == matchedParsed.key) then
                                        targetLineIndex = fIdx
                                        lines = freshLines
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if fileSha then
                lines[targetLineIndex] = newLine
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
                            ["User-Agent"] = "Warz-UniqueHUB-KeySystem",
                            ["Content-Type"] = "application/json"
                        },
                        Body = HttpService:JSONEncode({
                            message = "Auto-Lock Key " .. matchedParsed.key .. " to HWID " .. myHwid .. " (" .. (expireDateStr or "LIFETIME") .. ")",
                            content = newBase64,
                            sha = fileSha
                        })
                    })
                end)

                if putOk and putResp and (putResp.StatusCode == 200 or putResp.StatusCode == 201) then
                    KeySystem.CurrentKey = matchedParsed.key
                    KeySystem.ExpireTime = expireTimestamp
                    KeySystem.ExpireStr = expireDateStr
                    KeySystem.IsLifetime = (duration == nil or duration <= 0)
                    KeySystem.Verified = true
                    saveKeyLocal(cfg.SaveFileName, matchedParsed.key, myHwid, expireTimestamp, expireDateStr)

                    local successMsg = KeySystem.IsLifetime
                        and "คีย์ถูกต้อง! สิทธิ์ใช้งานถาวร (บันทึกล็อคเครื่องขึ้น GitHub เรียบร้อย)"
                        or ("คีย์ถูกต้อง! เปิดใช้งานสำเร็จ (หมดอายุ: " .. expireDateStr .. ")")
                    return true, successMsg, (duration and duration > 0 and duration or math.huge)
                else
                    warn("[KeySystem] เกิดข้อผิดพลาดในการ Auto-Commit ขึ้น GitHub:", putResp and putResp.Body)
                end
            end
        end

        -- บันทึกลงในเครื่อง (กรณีไม่มี Token หรือ Commit เกิดปัญหา)
        KeySystem.CurrentKey = matchedParsed.key
        KeySystem.ExpireTime = expireTimestamp
        KeySystem.ExpireStr = expireDateStr
        KeySystem.IsLifetime = (duration == nil or duration <= 0)
        KeySystem.Verified = true
        saveKeyLocal(cfg.SaveFileName, matchedParsed.key, myHwid, expireTimestamp, expireDateStr)

        local successMsg = KeySystem.IsLifetime
            and "คีย์ถูกต้อง! ยินดีต้อนรับเข้าสู่ระบบ (สิทธิ์ถาวร)"
            or ("คีย์ถูกต้อง! ยินดีต้อนรับเข้าสู่ระบบ (หมดอายุ: " .. (expireDateStr or "N/A") .. ")")
        return true, successMsg, (duration and duration > 0 and duration or math.huge)
    end

    return false, "เกิดข้อผิดพลาดในการตรวจสอบคีย์"
end

-- ══════════════════ IN-GAME WATERMARK HUD ══════════════════
function KeySystem.CreateWatermark(cfg)
    cfg = cfg or KeySystem.Config
    if KeySystem._WatermarkGui then
        pcall(function() KeySystem._WatermarkGui:Destroy() end)
        KeySystem._WatermarkGui = nil
    end

    local GuiParent = getSafeGuiParent()
    local wmGui = Create("ScreenGui", {
        Name = "Warz_TimeWatermark",
        ResetOnSpawn = false,
        DisplayOrder = 999,
        Parent = GuiParent,
    })
    KeySystem._WatermarkGui = wmGui

    local wmFrame = Create("Frame", {
        Name = "WatermarkFrame",
        Size = UDim2.new(0, 275, 0, 32),
        Position = UDim2.new(1, -285, 0, 10),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = wmGui,
    })
    RoundCorner(wmFrame, 8)
    AddStroke(wmFrame, KeyTheme.Border, 1)

    local dot = Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 10, 0.5, -4),
        BackgroundColor3 = KeyTheme.Green,
        BorderSizePixel = 0,
        Parent = wmFrame,
    })
    RoundCorner(dot, 4)

    local wmLabel = Create("TextLabel", {
        Text = "Warz | กำลังโหลดเวลา...",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = KeyTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Parent = wmFrame,
    })

    -- Draggable Badge
    local dragging, dragStart, startPos = false, nil, nil
    wmFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = wmFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    wmFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and dragStart then
                local delta = input.Position - dragStart
                wmFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    -- Live Countdown Updater (อัปเดตวินาทีแบบ Real-Time)
    task.spawn(function()
        while wmGui and wmGui.Parent and KeySystem.Verified do
            if KeySystem.ExpireTime and KeySystem.ExpireTime > 0 and not KeySystem.IsLifetime then
                local now = getServerNow()
                local diff = KeySystem.ExpireTime - now
                if diff <= 0 then
                    wmLabel.Text = "Warz | ⚠️ คีย์หมดอายุแล้ว"
                    wmLabel.TextColor3 = KeyTheme.Red
                    dot.BackgroundColor3 = KeyTheme.Red
                else
                    wmLabel.Text = "Warz | ⏳ " .. formatTimeCompact(diff)
                    wmLabel.TextColor3 = KeyTheme.Green
                    dot.BackgroundColor3 = KeyTheme.Green
                end
            elseif KeySystem.IsLifetime then
                wmLabel.Text = "Warz | ♾️ ถาวร (Lifetime)"
                wmLabel.TextColor3 = KeyTheme.Accent
                dot.BackgroundColor3 = KeyTheme.Accent
            end
            task.wait(1)
        end
    end)
end

-- ══════════════════ KEY SYSTEM UI ══════════════════
function KeySystem.OpenUI(cfg, onSuccessCallback)
    cfg = cfg or KeySystem.Config

    local GuiParent = getSafeGuiParent()

    -- ปิด UI เก่าทิ้งก่อนเปิดใหม่
    local guiName = (cfg.HubName or "Warz") .. "_KeyGUI"
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
        Size = UDim2.new(0, 400, 0, 485),
        Position = UDim2.new(0.5, -200, 0.5, -242),
        BackgroundColor3 = KeyTheme.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = KeyScreen,
    })
    RoundCorner(KeyWindow, 12)
    AddStroke(KeyWindow, KeyTheme.Border, 1)

    -- Header
    local KeyHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = KeyTheme.Header,
        BorderSizePixel = 0,
        Parent = KeyWindow,
    })
    RoundCorner(KeyHeader, 12)
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = KeyTheme.Header,
        BorderSizePixel = 0,
        Parent = KeyHeader,
    })

    local KeyDot = Create("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 14, 0.5, -5),
        BackgroundColor3 = KeyTheme.Yellow,
        BorderSizePixel = 0,
        Parent = KeyHeader,
    })
    RoundCorner(KeyDot, 5)

    Create("TextLabel", {
        Text = cfg.HubName or "Key System",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = KeyTheme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 6),
        Size = UDim2.new(0, 220, 0, 20),
        Parent = KeyHeader,
    })

    Create("TextLabel", {
        Text = cfg.Subtitle or "VISUALS & COMBAT • TIME-LIMITED KEY",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = KeyTheme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 26),
        Size = UDim2.new(0, 260, 0, 16),
        Parent = KeyHeader,
    })

    local KeyCloseBtn = Create("TextButton", {
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = KeyTheme.TextMuted,
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
        TextColor3 = KeyTheme.White,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0, 20),
        Parent = KeyBody,
    })

    Create("TextLabel", {
        Text = "คีย์จะถูกล็อคติดเครื่อง 1 คีย์ใช้งานได้แค่ 1 เครื่อง ป้องกันการส่งต่อ",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = KeyTheme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = KeyBody,
    })

    -- 1. กล่องใส่คีย์ (TextBox)
    local KeyInputCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = KeyTheme.Card,
        BorderSizePixel = 0,
        Parent = KeyBody,
    })
    RoundCorner(KeyInputCard, 8)
    AddStroke(KeyInputCard, KeyTheme.Border, 1)

    local KeyInput = Create("TextBox", {
        PlaceholderText = "กรอกคีย์ของคุณที่นี่ (เช่น PS-KEY-xxxx)...",
        PlaceholderColor3 = KeyTheme.TextMuted,
        Text = "",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = KeyTheme.White,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        ClearTextOnFocus = false,
        Parent = KeyInputCard,
    })

    -- 2. การ์ดแสดงเวลาที่เหลือแบบ Real-Time (Key Countdown Card)
    local TimeCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        Position = UDim2.new(0, 0, 0, 94),
        BackgroundColor3 = KeyTheme.Card,
        BorderSizePixel = 0,
        Parent = KeyBody,
    })
    RoundCorner(TimeCard, 8)
    AddStroke(TimeCard, KeyTheme.Border, 1)

    local TimeHeaderLabel = Create("TextLabel", {
        Text = "⏱️ สถานะอายุการใช้งาน (Remaining Time):",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = KeyTheme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = TimeCard,
    })

    local TimeCountdownLabel = Create("TextLabel", {
        Text = "รอการตรวจสอบคีย์",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = KeyTheme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -24, 0, 20),
        Parent = TimeCard,
    })

    -- 3. การ์ดแสดง HWID ของเครื่อง
    local HwidCard = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 74),
        Position = UDim2.new(0, 0, 0, 154),
        BackgroundColor3 = KeyTheme.Card,
        BorderSizePixel = 0,
        Parent = KeyBody,
    })
    RoundCorner(HwidCard, 8)
    AddStroke(HwidCard, KeyTheme.Border, 1)

    Create("TextLabel", {
        Text = "💻 รหัสเครื่องของคุณ (Hardware ID):",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = KeyTheme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = HwidCard,
    })

    local myHwidStr = KeySystem.GetHWID()
    local displayHwid = string.sub(myHwidStr, 1, 24) .. (string.len(myHwidStr) > 24 and "..." or "")

    Create("TextLabel", {
        Text = displayHwid,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = KeyTheme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -125, 0, 20),
        Parent = HwidCard,
    })

    -- ปุ่มคัดลอก HWID
    local CopyHwidBtn = Create("TextButton", {
        Text = "📋 คัดลอก HWID",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = KeyTheme.White,
        BackgroundColor3 = KeyTheme.CardHover,
        Size = UDim2.new(0, 105, 0, 26),
        Position = UDim2.new(1, -117, 0, 21),
        AutoButtonColor = false,
        Parent = HwidCard,
    })
    RoundCorner(CopyHwidBtn, 6)
    CopyHwidBtn.MouseButton1Click:Connect(function()
        KeySystem.CopyHWID()
        CopyHwidBtn.Text = "✓ คัดลอกแล้ว!"
        CopyHwidBtn.BackgroundColor3 = KeyTheme.Green
        task.delay(1.5, function()
            CopyHwidBtn.Text = "📋 คัดลอก HWID"
            CopyHwidBtn.BackgroundColor3 = KeyTheme.CardHover
        end)
    end)

    Create("TextLabel", {
        Text = "หากคีย์ติดล็อคเครื่อง ให้ส่ง HWID นี้ให้แอดมินเพื่อรีเซ็ตหรือปลดล็อค",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(130, 130, 145),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 48),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = HwidCard,
    })

    -- 4. ข้อความผลการตรวจสอบ
    local KeyStatusMsg = Create("TextLabel", {
        Text = "พร้อมตรวจสอบคีย์",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = KeyTheme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 236),
        Size = UDim2.new(1, 0, 0, 22),
        Parent = KeyBody,
    })

    -- 5. ปุ่มยืนยันคีย์ (SUBMIT KEY)
    local SubmitBtn = Create("TextButton", {
        Text = "✓  ยืนยันคีย์ (SUBMIT KEY)",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = KeyTheme.White,
        BackgroundColor3 = KeyTheme.Green,
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 0, 264),
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
            KeyStatusMsg.TextColor3 = KeyTheme.Red
            return
        end

        isChecking = true
        SubmitBtn.Text = "⏳ กำลังตรวจสอบและล็อค HWID..."
        SubmitBtn.BackgroundColor3 = KeyTheme.CardHover
        KeyStatusMsg.Text = "กำลังติดต่อระบบ GitHub เพื่อยืนยัน..."
        KeyStatusMsg.TextColor3 = KeyTheme.Yellow
        KeyDot.BackgroundColor3 = KeyTheme.Yellow

        task.spawn(function()
            local success, msg, remaining = KeySystem.VerifyOnline(input, cfg)
            isChecking = false

            if success then
                KeyStatusMsg.Text = "✓ " .. msg
                KeyStatusMsg.TextColor3 = KeyTheme.Green
                KeyDot.BackgroundColor3 = KeyTheme.Green
                SubmitBtn.Text = "✓ สำเร็จ! กำลังเปิดโปรแกรม..."
                SubmitBtn.BackgroundColor3 = KeyTheme.Green

                pcall(function()
                    local noteText = KeySystem.IsLifetime
                        and "ยืนยันคีย์สำเร็จ! สิทธิ์การใช้งานถาวร"
                        or ("ยืนยันคีย์สำเร็จ! เหลือเวลา: " .. formatTimeRemaining(remaining or 0))
                    StarterGui:SetCore("SendNotification", {
                        Title = cfg.HubName or "Key System",
                        Text = noteText,
                        Duration = 4
                    })
                end)

                task.wait(0.8)
                KeyScreen:Destroy()

                if onSuccessCallback then
                    task.spawn(onSuccessCallback)
                end
            else
                KeyStatusMsg.Text = "✗ " .. msg
                KeyStatusMsg.TextColor3 = KeyTheme.Red
                KeyDot.BackgroundColor3 = KeyTheme.Red
                SubmitBtn.Text = "✓  ยืนยันคีย์ (SUBMIT KEY)"
                SubmitBtn.BackgroundColor3 = KeyTheme.Green
            end
        end)
    end)

    -- 6. ปุ่มวาง / ล้างข้อความ / รับคีย์
    local PasteRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 314),
        BackgroundTransparency = 1,
        Parent = KeyBody,
    })
    Create("UIListLayout", {
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
        TextColor3 = KeyTheme.TextMuted,
        BackgroundColor3 = KeyTheme.Card,
        Size = UDim2.new(btnWidthScale, 0, 1, 0),
        AutoButtonColor = false,
        Parent = PasteRow,
    })
    RoundCorner(PasteBtn, 6)

    local ClearBtn = Create("TextButton", {
        Text = "🗑 ล้าง",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = KeyTheme.TextMuted,
        BackgroundColor3 = KeyTheme.Card,
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
            TextColor3 = KeyTheme.Yellow,
            BackgroundColor3 = KeyTheme.Card,
            Size = UDim2.new(btnWidthScale, 0, 1, 0),
            AutoButtonColor = false,
            Parent = PasteRow,
        })
        RoundCorner(GetKeyBtn, 6)
        GetKeyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(cfg.GetKeyUrl)
            GetKeyBtn.Text = "✓ คัดลอกแล้ว"
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

    -- 7. Footer
    Create("TextLabel", {
        Text = (cfg.HubName or "Warz By Unique HUB") .. " • GitHub REST Verified • HWID Locked",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(110, 110, 125),
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 355),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = KeyBody,
    })

    -- ดึงข้อมูลคีย์เซฟเดิมมาแสดงเบื้องต้น (ถ้ามี)
    local saved = readKeyLocal(cfg.SaveFileName)
    if saved and saved.key then
        KeyInput.Text = saved.key
        if saved.expireTimestamp and saved.expireTimestamp > 0 then
            KeySystem.ExpireTime = saved.expireTimestamp
            KeySystem.ExpireStr = saved.expireStr
            KeySystem.IsLifetime = false
        elseif saved.expireStr == "LIFETIME" then
            KeySystem.IsLifetime = true
        end
    end

    -- ระบบอัปเดตเวลานับถอยหลังแบบ Real-time บน UI
    task.spawn(function()
        while KeyScreen and KeyScreen.Parent do
            if KeySystem.ExpireTime and KeySystem.ExpireTime > 0 and not KeySystem.IsLifetime then
                local now = getServerNow()
                local diff = KeySystem.ExpireTime - now
                if diff <= 0 then
                    TimeCountdownLabel.Text = "⚠️ คีย์หมดอายุแล้ว"
                    TimeCountdownLabel.TextColor3 = KeyTheme.Red
                else
                    TimeCountdownLabel.Text = "⏳ เหลือเวลา: " .. formatTimeRemaining(diff)
                    TimeCountdownLabel.TextColor3 = KeyTheme.Green
                end
            elseif KeySystem.IsLifetime then
                TimeCountdownLabel.Text = "♾️ สิทธิ์การใช้งาน: ถาวร (LIFETIME)"
                TimeCountdownLabel.TextColor3 = KeyTheme.Accent
            else
                TimeCountdownLabel.Text = "⏱️ รอการตรวจสอบคีย์ (เริ่มนับเวลาเมื่อใช้ครั้งแรก)"
                TimeCountdownLabel.TextColor3 = KeyTheme.TextMuted
            end
            task.wait(1)
        end
    end)

    -- Draggable Header
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

-- ══════════════════ WATCHDOG & RE-CHECK LOGIC ══════════════════
function KeySystem.StartWatchdog(activeKey, cfg)
    if KeySystem._WatchdogRunning then return end
    KeySystem._WatchdogRunning = true

    task.spawn(function()
        local interval = cfg.WatchdogInterval or 10
        local lastOnlineCheck = 0

        while KeySystem._WatchdogRunning and KeySystem.Verified do
            -- 1. ตรวจสอบเวลาหมดอายุจริงแบบความถี่สูงทุกวินาที (High Precision Countdown)
            local now = getServerNow()
            if KeySystem.ExpireTime and KeySystem.ExpireTime > 0 and not KeySystem.IsLifetime then
                if now >= KeySystem.ExpireTime then
                    -- ⚠️ คีย์หมดอายุแล้ว!
                    KeySystem.Verified = false
                    KeySystem._WatchdogRunning = false
                    KeySystem.DeleteKeyLocal(cfg.SaveFileName)

                    -- ตัดการทำงานและทำลาย Fluent UI ทันที
                    pcall(function()
                        if _G.WarzWindow and _G.WarzWindow.Destroy then _G.WarzWindow:Destroy() end
                        if _G.WarzFluent and _G.WarzFluent.Destroy then
                            _G.WarzFluent:Destroy()
                        elseif _G.WarzFluent and _G.WarzFluent.GUI then
                            _G.WarzFluent.GUI:Destroy()
                        end
                    end)

                    -- ลบ Watermark HUD
                    if KeySystem._WatermarkGui then
                        pcall(function() KeySystem._WatermarkGui:Destroy() end)
                        KeySystem._WatermarkGui = nil
                    end

                    -- แจ้งเตือนและเตะผู้เล่นออกจากเกมทันที
                    pcall(function()
                        LocalPlayer:Kick("\n[Warz By Unique HUB]\n⚠️ คีย์ของคุณหมดอายุการใช้งานแล้ว!\nกรุณาติดต่อแอดมินเพื่อขอรับหรือต่ออายุคีย์ใหม่")
                    end)
                    break
                end
            end

            -- 2. ตรวจสอบสถานะคีย์บน GitHub สดๆ ทุกๆ N วินาที (WatchdogInterval = 10 วินาที)
            if (tick() - lastOnlineCheck) >= interval then
                lastOnlineCheck = tick()

                local ok, msg = KeySystem.VerifyOnline(activeKey, cfg)
                if not ok then
                    -- คีย์หมดอายุ หรือถูกเพิกถอน หรือถูกลบจาก GitHub ขณะเล่นอยู่!
                    KeySystem.Verified = false
                    KeySystem._WatchdogRunning = false
                    KeySystem.DeleteKeyLocal(cfg.SaveFileName)

                    pcall(function()
                        if _G.WarzWindow and _G.WarzWindow.Destroy then _G.WarzWindow:Destroy() end
                        if _G.WarzFluent and _G.WarzFluent.Destroy then
                            _G.WarzFluent:Destroy()
                        elseif _G.WarzFluent and _G.WarzFluent.GUI then
                            _G.WarzFluent.GUI:Destroy()
                        end
                    end)

                    if KeySystem._WatermarkGui then
                        pcall(function() KeySystem._WatermarkGui:Destroy() end)
                        KeySystem._WatermarkGui = nil
                    end

                    local kickMsg = "\n[Warz By Unique HUB]\n⚠️ คีย์ของคุณหมดอายุ หรือถูกเพิกถอนจากระบบ GitHub แล้ว!\n" .. tostring(msg)
                    pcall(function()
                        LocalPlayer:Kick(kickMsg)
                    end)
                    break
                end
            end

            task.wait(1)
        end
    end)
end

-- ══════════════════ ฟังก์ชันเริ่มต้นทำงาน (START / INIT) ══════════════════
function KeySystem.Start(customConfig, onSuccessCallback)
    local cfg = {}
    for k, v in pairs(KeySystem.Config) do cfg[k] = v end
    if typeof(customConfig) == "table" then
        for k, v in pairs(customConfig) do cfg[k] = v end
    end

    -- 1. ตรวจสอบคีย์ที่บันทึกไว้ในเครื่อง (Auto Login)
    if cfg.AutoLogin then
        local saved = readKeyLocal(cfg.SaveFileName)
        local myHwid = KeySystem.GetHWID()

        if saved and saved.key and saved.hwid and compareHWID(saved.hwid, myHwid) then
            -- ตรวจสอบคีย์สดใหม่ผ่าน GitHub
            local ok, msg = KeySystem.VerifyOnline(saved.key, cfg)
            if ok then
                pcall(function()
                    local noteText = KeySystem.IsLifetime
                        and "เข้าสู่ระบบอัตโนมัติสำเร็จ! สิทธิ์การใช้งานถาวร"
                        or ("เข้าสู่ระบบอัตโนมัติสำเร็จ! เหลือเวลา: " .. formatTimeRemaining((KeySystem.ExpireTime or 0) - getServerNow()))
                    StarterGui:SetCore("SendNotification", {
                        Title = cfg.HubName or "Key System",
                        Text = noteText,
                        Duration = 3
                    })
                end)
                if onSuccessCallback then
                    task.spawn(onSuccessCallback)
                end
                KeySystem.StartWatchdog(saved.key, cfg)
                KeySystem.CreateWatermark(cfg)
                return
            else
                -- หากคีย์หมดอายุ หรือไม่พบคีย์ใน GitHub ให้ลบไฟล์เซฟทิ้งอัตโนมัติ และเปิดหน้า UI ทันที!
                KeySystem.DeleteKeyLocal(cfg.SaveFileName)
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = cfg.HubName or "Key System",
                        Text = "คีย์ที่บันทึกไว้หมดอายุหรือไม่ถูกต้องแล้ว กรุณากรอกคีย์ใหม่",
                        Duration = 4
                    })
                end)
            end
        end
    end

    -- 2. หากยังไม่มีคีย์เซฟ หรือคีย์หมดอายุ ให้เปิด UI ให้กรอกคีย์ใหม่
    KeySystem.OpenUI(cfg, function()
        if onSuccessCallback then
            task.spawn(onSuccessCallback)
        end
        if KeySystem.CurrentKey then
            KeySystem.StartWatchdog(KeySystem.CurrentKey, cfg)
            KeySystem.CreateWatermark(cfg)
        end
    end)
end

-- ========================================================
-- WARZ MAIN SCRIPT EXECUTION
-- ========================================================
local function RunWarzScript()
    if _G.WarzScriptRunning then
        pcall(function()
            if _G.WarzWindow and _G.WarzWindow.Destroy then _G.WarzWindow:Destroy() end
            if _G.WarzFluent and _G.WarzFluent.Destroy then _G.WarzFluent:Destroy() end
        end)
    end
    _G.WarzScriptRunning = true
    _G.WarzStartFunction = RunWarzScript

    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    _G.WarzFluent = Fluent

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- CONFIGURATION
-- ========================================================
local ESP_Config = {
    Enabled = true,
    TeamCheck = false,
    ShowBoxes = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracers = false,
    TracerOrigin = "Bottom",
    ShowHighlight = true,

    -- Colors
    EnemyColor = Color3.fromRGB(255, 60, 60),
    TeamColor = Color3.fromRGB(60, 180, 255),
    HighlightOutline = Color3.fromRGB(255, 255, 255),

    -- Sliders
    MaxDistance = 1500,
    TextSize = 13,
    HighlightFillTransparency = 0.5,
    HighlightOutlineTransparency = 0
}

local Combat_Config = {
    -- Aimbot
    AimbotEnabled = false,
    AimMode = "Hard Lock", -- "Hard Lock", "Smooth Cam", "Mouse Delta"
    AimKey1 = "Right Click", -- Key 1: "Right Click", "Left Click", "Left Alt", "Left Shift", "E", "C", "Always Active", "None"
    AimKey2 = "Left Click",  -- Key 2: "Left Click", "Right Click", "Left Alt", "Left Shift", "E", "C", "Always Active", "None"
    AimbotPart = "Head", -- "Head", "HumanoidRootPart"
    Smoothness = 5, -- Higher = smoother & slower pull
    MaxAimbotDistance = 600,
    FOVRadius = 150,
    ShowFOVCircle = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    WallCheck = true,

    -- Visual Fixes & Bullet Tracers
    NoMuzzleFlash = true,
    BulletTracers = true -- Keep and enhance bullet tracer lines for recoil control
}

local Med_Config = {
    Enabled = false,
    HealthLossPercent = 10, -- Triggers when HP lost >= 10% (i.e. HP <= 90%)
    Delay = 0.8, -- Cooldown delay between med cycles in seconds
    KeyDelay = 0.08, -- Delay between key presses 3 -> 3 -> 1
    LoopUntilFull = true -- Keep pumping until HP returns to 100%
}

local Item_Config = {
    -- Item ESP
    ESPEnabled = false,
    ESPMaxDistance = 500,
    TextSize = 13,
    SelectedItems = {}, -- Multi-select: { ["Medkit"] = true, ... }

    -- Category filters
    FilterWeapons = true,
    FilterAmmo = true,
    FilterMedical = true,
    FilterShields = true,
    FilterArmor = true,
    FilterAttachments = true,
    FilterOther = true,

    -- Item Highlight (Chams 3D)
    HighlightEnabled = true,
    HighlightFillTransparency = 0.4,
    HighlightOutlineTransparency = 0,

    -- Category Colors (Defaults matching user requirements)
    ColorWeapons = Color3.fromRGB(0, 200, 255),       -- ฟ้า/น้ำเงิน (Cyan/Blue)
    ColorMedical = Color3.fromRGB(50, 255, 100),      -- เขียว (Green)
    ColorShields = Color3.fromRGB(255, 50, 50),       -- แดง (Red)
    ColorArmor = Color3.fromRGB(180, 50, 255),        -- ม่วง (Purple)
    ColorAmmo = Color3.fromRGB(255, 160, 20),         -- ส้ม (Orange)
    ColorAttachments = Color3.fromRGB(255, 100, 200), -- ชมพู (Pink)
    ColorOther = Color3.fromRGB(230, 230, 230),       -- ขาว (White)

    -- Auto Loot
    AutoLootEnabled = false,
    AutoLootRadius = 25,
    AutoLootDelay = 0.15,
    AutoLootHoldTime = 1.1,
    AutoLootFilterOnly = false
}

-- ========================================================
-- DYNAMIC ITEM CATALOG LOADER
-- ========================================================
local ItemNamesList = {}
pcall(function()
    local cfg = require(ReplicatedStorage.Shared.Config)
    local seen = {}
    local function addItem(id, name)
        local itemDisplayName = name or id
        if not seen[itemDisplayName] and itemDisplayName and itemDisplayName ~= "" and itemDisplayName ~= "Unarmed" then
            seen[itemDisplayName] = true
            table.insert(ItemNamesList, itemDisplayName)
        end
    end

    if type(cfg.Shop) == "table" then
        for id, _ in pairs(cfg.Shop) do
            local info = cfg.ShopItem(id)
            addItem(id, info and info.Name or id)
        end
    end

    for _, folderName in ipairs({"ViewGunMeshes", "ViewItemMeshes"}) do
        local f = ReplicatedStorage:FindFirstChild(folderName)
        if f then
            for _, c in ipairs(f:GetChildren()) do
                local info = cfg.ShopItem(c.Name)
                addItem(c.Name, info and info.Name or c.Name)
            end
        end
    end
end)

if #ItemNamesList == 0 then
    ItemNamesList = {
        ".308 Winchester", "ARMOR CITYSS2FTK", "ARMOR COMBAFTK", "ARMOR CORSAIR",
        "ARMOR SPIDERMANFTK", "AW CITYSS2FTK", "BLASER R93", "Bandages",
        "Bandages DX", "Binoculars", "Cobba shield", "Compact Scope",
        "Custom Guerilla", "Custom Guerilla · มุมน้ำเงิน", "Custom Guerilla · มุมแดง",
        "Flashlight", "HAND CORSAIR", "Hatchet", "Honey Badger", "Honey COMBAFTK",
        "IMI TAR-21", "K. Style Helmet", "K. Style Helmet · มุมน้ำเงิน",
        "K. Style Helmet · มุมแดง", "Katana", "Kobra", "LS90 SPIDERMANFTK",
        "M134 COBBAFTK", "M134 SPIDERMANFTK", "MOTO CITYSS2FTK", "MOTO COBBAFTK",
        "MOTO SPIDERRMANFTK", "Medkit", "Pistol laser", "Red Dot SP",
        "Reflex Sight", "Riot Shield", "SCAR CITYSS2FTK", "SIG CORSAIR",
        "SIG SAUER 556", "SMG-20", "SMG-40", "SP SPIDERMANFTK", "STANAG 30",
        "STANAG 60", "STANAG C-Mag", "Swiss Arms Scope 8x", "UZI", "VSS CITYSS2FTK",
        "VSS COBBAFTK", "VSS CORSAIR", "VSS VINTOREZ", "VSS-10", "Wood Shield Bar",
        "น้ำฟื้น Stamina", "เบ็ดตกปลา", "เบ็ดใยทมิฬ", "เหยื่อ Chubby", "เหยื่อแมงมุมใยทมิฬ"
    }
end

table.sort(ItemNamesList, function(a, b)
    return a:lower() < b:lower()
end)

-- ========================================================
-- WARZ CAMERA ENGINE LINK
-- ========================================================
local WarzCamMod = nil

local function resolveWarzCamera()
    if WarzCamMod then return WarzCamMod end
    pcall(function()
        local getlm = getloadedmodules or (syn and syn.getloadedmodules)
        if getlm then
            for _, m in ipairs(getlm()) do
                if m.Name == "WarzCamera" then
                    WarzCamMod = require(m)
                    break
                end
            end
        end
        if not WarzCamMod and LocalPlayer:FindFirstChild("PlayerScripts") then
            local client = LocalPlayer.PlayerScripts:FindFirstChild("Client")
            local world = client and client:FindFirstChild("world")
            local cam = world and world:FindFirstChild("WarzCamera")
            if cam then
                WarzCamMod = require(cam)
            end
        end
    end)
    return WarzCamMod
end

task.spawn(function()
    while not WarzCamMod do
        resolveWarzCamera()
        task.wait(1)
    end
end)

local function setCameraAngles(yaw, pitch)
    local cam = resolveWarzCamera()
    if cam then
        local setup = debug.setupvalue or setupvalue
        if setup then
            local ok = pcall(function()
                setup(cam.GetYaw, 1, yaw)
                setup(cam.GetPitch, 1, pitch)
            end)
            if ok then return true end
        end
    end
    return false
end

-- ========================================================
-- HELPER FUNCTIONS & CATEGORIES
-- ========================================================
local function getItemCategory(itemId)
    itemId = tostring(itemId or "")
    local lowId = itemId:lower()

    -- 1. Keyword fast classification (Guaranteed detection for weapons, meds, shields, armor, etc.)
    -- Shields (Check first before Armor so shields aren't treated as general armor!)
    if lowId:find("shield") or lowId:find("barricade") then
        return "Shields", Item_Config.ColorShields or Color3.fromRGB(255, 50, 50)
    -- Ammo
    elseif lowId:find("stanag") or lowId:find("mag") or lowId:find("ammo") or lowId:find("drum") or lowId:find("clip") or lowId:find("bullet") or lowId:find("round") or lowId:find("shell") or lowId:find("5.56") or lowId:find("7.62") or lowId:find(".308") then
        return "Ammo", Item_Config.ColorAmmo or Color3.fromRGB(255, 160, 20)
    -- Medical
    elseif lowId:find("bandage") or lowId:find("medkit") or lowId:find("painkiller") or lowId:find("blood") or lowId:find("syringe") or lowId:find("pill") or lowId:find("firstaid") or lowId:find("health") or lowId:find("stamina") or lowId:find("น้ำฟื้น") then
        return "Medical", Item_Config.ColorMedical or Color3.fromRGB(50, 255, 100)
    -- Weapons
    elseif lowId:find("asr") or lowId:find("smg") or lowId:find("snp") or lowId:find("shotgun") or lowId:find("pistol") or lowId:find("rifle") or lowId:find("gun") or lowId:find("m4") or lowId:find("ak") or lowId:find("awm") or lowId:find("scar") or lowId:find("honey") or lowId:find("m134") or lowId:find("tar") or lowId:find("sig") or lowId:find("knife") or lowId:find("katana") or lowId:find("sword") or lowId:find("melee") or lowId:find("hatchet") or lowId:find("uzi") or lowId:find("blaser") or lowId:find("vss") then
        return "Weapons", Item_Config.ColorWeapons or Color3.fromRGB(0, 200, 255)
    -- Armor
    elseif lowId:find("armor") or lowId:find("vest") or lowId:find("helmet") or lowId:find("backpack") or lowId:find("bag") or lowId:find("guerilla") or lowId:find("moto") or lowId:find("corsair") or lowId:find("combftk") then
        return "Armor", Item_Config.ColorArmor or Color3.fromRGB(180, 50, 255)
    -- Attachments
    elseif lowId:find("optic") or lowId:find("scope") or lowId:find("sight") or lowId:find("laser") or lowId:find("suppressor") or lowId:find("silencer") or lowId:find("grip") or lowId:find("flash") or lowId:find("kobra") or lowId:find("red dot") or lowId:find("compact") or lowId:find("reflex") then
        return "Attachments", Item_Config.ColorAttachments or Color3.fromRGB(255, 100, 200)
    end

    -- 2. Check ReplicatedStorage.Shared.Config
    local success, cfg = pcall(function()
        return require(ReplicatedStorage.Shared.Config)
    end)
    if success and cfg then
        local shopItem = (cfg.ShopItem and cfg.ShopItem(itemId))
            or (cfg.ShopItem and cfg.ShopItem(itemId:gsub(" ", "_")))
            or (cfg.Shop and (cfg.Shop[itemId] or cfg.Shop[itemId:gsub(" ", "_")]))
        if not shopItem and cfg.Shop then
            for _, itemData in pairs(cfg.Shop) do
                if type(itemData) == "table" and (itemData.Name == itemId or itemData.Id == itemId) then
                    shopItem = itemData
                    break
                end
            end
        end

        local kind = shopItem and shopItem.Kind or ""
        local storeCat = shopItem and shopItem.StoreCat or ""

        if kind == "Shield" or storeCat == "Shields" or tostring(shopItem and shopItem.Name or ""):lower():find("shield") then
            return "Shields", Item_Config.ColorShields or Color3.fromRGB(255, 50, 50)
        elseif kind == "ASR" or kind == "SMG" or kind == "SNP" or kind == "MELEE" or storeCat == "Weapons" then
            return "Weapons", Item_Config.ColorWeapons or Color3.fromRGB(0, 200, 255)
        elseif kind == "Magazine" or storeCat == "Magazines" or storeCat == "Ammo" then
            return "Ammo", Item_Config.ColorAmmo or Color3.fromRGB(255, 160, 20)
        elseif kind == "Medical" or storeCat == "Medical" then
            return "Medical", Item_Config.ColorMedical or Color3.fromRGB(50, 255, 100)
        elseif kind == "Armor" or kind == "Helmet" or kind == "Bag" or storeCat == "Armor" or storeCat == "Gears" then
            return "Armor", Item_Config.ColorArmor or Color3.fromRGB(180, 50, 255)
        elseif kind == "Optic" or kind == "Laser" or kind == "Attm" or storeCat == "Attachments" then
            return "Attachments", Item_Config.ColorAttachments or Color3.fromRGB(255, 100, 200)
        end
    end

    return "Other", Item_Config.ColorOther or Color3.fromRGB(230, 230, 230)
end

local function shouldDisplayItem(name, itemId, category)
    -- Multi-select Item Names check
    local hasSpecificSelection = false
    for _, isSelected in pairs(Item_Config.SelectedItems) do
        if isSelected then
            hasSpecificSelection = true
            break
        end
    end

    if hasSpecificSelection then
        local matched = false
        if Item_Config.SelectedItems[name] or Item_Config.SelectedItems[itemId] then
            matched = true
        else
            for selName, isSelected in pairs(Item_Config.SelectedItems) do
                if isSelected then
                    local lowSel = selName:lower()
                    if name:lower() == lowSel or itemId:lower() == lowSel or name:lower():find(lowSel, 1, true) or itemId:lower():find(lowSel, 1, true) then
                        matched = true
                        break
                    end
                end
            end
        end
        if not matched then
            return false
        end
    end

    -- Category filter
    if category == "Weapons" and Item_Config.FilterWeapons then return true end
    if category == "Ammo" and Item_Config.FilterAmmo then return true end
    if category == "Medical" and Item_Config.FilterMedical then return true end
    if category == "Shields" and Item_Config.FilterShields then return true end
    if category == "Armor" and Item_Config.FilterArmor then return true end
    if category == "Attachments" and Item_Config.FilterAttachments then return true end
    if category == "Other" and Item_Config.FilterOther then return true end

    return false
end

-- ========================================================
-- PLAYER ESP ENGINE (DUAL LAYER: BILLBOARDGUI + DRAWING + CHAMS)
-- ========================================================
local ESP_Cache = {}

local function getPlayerVisualModel(player)
    if not player or player == LocalPlayer or player.UserId == LocalPlayer.UserId then return nil end
    local pName = string.lower(player.Name)
    local localName = string.lower(LocalPlayer.Name)
    local hvl = workspace:FindFirstChild("HeroVisualsLocal")
    if hvl then
        for _, folder in ipairs(hvl:GetChildren()) do
            local fName = string.lower(folder.Name)
            local isLocal = (fName == localName) or (fName:find("_" .. localName, 1, true) ~= nil)
            if not isLocal then
                if fName == pName or fName:find("_" .. pName, 1, true) or fName:sub(-#pName) == pName then
                    local liveAim = folder:FindFirstChild("LiveAim") or folder:FindFirstChildWhichIsA("Model")
                    if liveAim then return liveAim end
                end
            end
        end
    end
    return player.Character
end

-- Proxy object wrapper that provides .Position and delegates methods to underlying instance
local function makeAimTarget(pos, inst)
    return setmetatable({
        Position = pos,
        Instance = inst
    }, {
        __index = function(self, k)
            if k == "Position" then return pos end
            if inst then
                local v = inst[k]
                if typeof(v) == "function" then
                    return function(_, ...)
                        return v(inst, ...)
                    end
                end
                return v
            end
            return nil
        end
    })
end

local function getPlayerAimPart(player, partName)
    if not player then return nil end
    partName = partName or Combat_Config.AimbotPart or "Head"

    local char = player.Character
    local visualModel = getPlayerVisualModel(player)
    local targetModel = visualModel or char
    if not targetModel or not targetModel:IsDescendantOf(workspace) then return nil end

    local hrp = (char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart))
        or (visualModel and (visualModel:FindFirstChild("RootPart") or visualModel:FindFirstChildWhichIsA("BasePart")))

    -- 1. Search for Skinned Mesh Bones first (WarZ character rigs use Bip01 bones which track prone/crouch animation directly)
    if partName == "Head" then
        for _, d in ipairs(targetModel:GetDescendants()) do
            if d:IsA("Bone") and (d.Name == "Bip01_Head" or d.Name:lower():find("head")) then
                local ok, cf = pcall(function() return d.TransformedWorldCFrame end)
                if ok and cf and cf.Position then
                    return makeAimTarget(cf.Position, d)
                end
                local ok2, wp = pcall(function() return d.WorldPosition end)
                if ok2 and wp then
                    return makeAimTarget(wp, d)
                end
            end
        end
    else
        for _, d in ipairs(targetModel:GetDescendants()) do
            if d:IsA("Bone") and (d.Name:find("Spine") or d.Name:find("Pelvis") or d.Name:lower():find("torso")) then
                local ok, cf = pcall(function() return d.TransformedWorldCFrame end)
                if ok and cf and cf.Position then
                    return makeAimTarget(cf.Position, d)
                end
                local ok2, wp = pcall(function() return d.WorldPosition end)
                if ok2 and wp then
                    return makeAimTarget(wp, d)
                end
            end
        end
    end

    -- 2. BasePart fallback with stance-aware positioning
    local basePart = nil
    if partName == "Head" then
        basePart = targetModel:FindFirstChild("Head") or targetModel:FindFirstChild("head")
            or (char and (char:FindFirstChild("Head") or char:FindFirstChild("head")))
    end
    if not basePart then
        basePart = targetModel:FindFirstChild(partName)
            or targetModel:FindFirstChild("UpperTorso")
            or targetModel:FindFirstChild("Torso")
            or hrp
            or (char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char.PrimaryPart))
    end

    if basePart and basePart:IsA("BasePart") then
        local rawPos = basePart.Position
        local stance = player:GetAttribute("CSGO_Stance") or (char and char:GetAttribute("CSGO_Stance")) or ""

        -- If target is prone and we only have static BasePart, calculate true ground position
        if stance:find("PRONE") or (hrp and (rawPos.Y - hrp.Position.Y) < -0.5) then
            if hrp then
                local look = hrp.CFrame.LookVector
                -- Prone head is lowered to ~1 stud above ground and extends forward
                local proneHeadPos = hrp.Position - Vector3.new(0, 2.2, 0) + look * (partName == "Head" and 1.8 or 0.2)
                return makeAimTarget(proneHeadPos, basePart)
            end
        -- If target is crouching
        elseif stance:find("CROUCH") or (hrp and (rawPos.Y - hrp.Position.Y) < 0.6) then
            if hrp and partName == "Head" then
                local crouchHeadPos = hrp.Position + Vector3.new(0, 0.4, 0)
                return makeAimTarget(crouchHeadPos, basePart)
            end
        end

        return basePart
    end

    return nil
end

local function isTeammate(player)
    if not ESP_Config.TeamCheck then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

local function getESPColor(player)
    local col = isTeammate(player) and ESP_Config.TeamColor or ESP_Config.EnemyColor
    if typeof(col) ~= "Color3" then
        return isTeammate(player) and Color3.fromRGB(60, 180, 255) or Color3.fromRGB(255, 60, 60)
    end
    return col
end

local function hideDrawing(esp)
    if not esp then return end
    pcall(function()
        if esp.BoxBillboard then esp.BoxBillboard.Enabled = false end
        if esp.InfoBillboard then esp.InfoBillboard.Enabled = false end
        if esp.Highlight then esp.Highlight.Enabled = false end
        if esp.Tracer then esp.Tracer.Visible = false end
    end)
end

local function createESP(player)
    if not player or player == LocalPlayer or player.UserId == LocalPlayer.UserId then return end
    if ESP_Cache[player] then return end

    local drawings = {
        BoxBillboard = nil,
        BoxFrame = nil,
        BoxStroke = nil,

        InfoBillboard = nil,
        NameLabel = nil,
        DistLabel = nil,
        HpBg = nil,
        HpFill = nil,

        Highlight = nil,
        Tracer = nil
    }

    -- 1. Native Roblox 2D Box BillboardGui (Locked 100% to 3D character, zero jitter, zero lag)
    pcall(function()
        local boxBbg = Instance.new("BillboardGui")
        boxBbg.Name = "WarZ_ESP_Box"
        boxBbg.AlwaysOnTop = true
        boxBbg.Size = UDim2.new(4.0, 0, 5.8, 0)
        boxBbg.StudsOffset = Vector3.new(0, 0, 0)
        boxBbg.ClipsDescendants = false
        boxBbg.Enabled = false

        local boxFrame = Instance.new("Frame", boxBbg)
        boxFrame.Name = "BoxFrame"
        boxFrame.Size = UDim2.new(1, 0, 1, 0)
        boxFrame.BackgroundTransparency = 1

        local boxStroke = Instance.new("UIStroke", boxFrame)
        boxStroke.Color = getESPColor(player)
        boxStroke.Thickness = 1.6

        drawings.BoxBillboard = boxBbg
        drawings.BoxFrame = boxFrame
        drawings.BoxStroke = boxStroke
    end)

    -- 2. Native Roblox Info BillboardGui (Crisp Name, Distance & Health Bar above player head)
    pcall(function()
        local infoBbg = Instance.new("BillboardGui")
        infoBbg.Name = "WarZ_ESP_Info"
        infoBbg.AlwaysOnTop = true
        infoBbg.Size = UDim2.new(0, 160, 0, 48)
        infoBbg.StudsOffset = Vector3.new(0, 1.4, 0)
        infoBbg.ClipsDescendants = false
        infoBbg.Enabled = false

        local nameLabel = Instance.new("TextLabel", infoBbg)
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0, 18)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName or player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextSize = ESP_Config.TextSize or 13
        nameLabel.Font = Enum.Font.SourceSansBold

        local distLabel = Instance.new("TextLabel", infoBbg)
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 0, 17)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "[0 m]"
        distLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.TextSize = math.max(10, (ESP_Config.TextSize or 13) - 1)
        distLabel.Font = Enum.Font.SourceSans

        local hpBg = Instance.new("Frame", infoBbg)
        hpBg.Name = "HpBg"
        hpBg.Size = UDim2.new(0, 80, 0, 4)
        hpBg.Position = UDim2.new(0.5, -40, 0, 33)
        hpBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        hpBg.BorderSizePixel = 0

        local hpStroke = Instance.new("UIStroke", hpBg)
        hpStroke.Color = Color3.fromRGB(0, 0, 0)
        hpStroke.Thickness = 1

        local hpFill = Instance.new("Frame", hpBg)
        hpFill.Name = "HpFill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.Position = UDim2.new(0, 0, 0, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpFill.BorderSizePixel = 0

        drawings.InfoBillboard = infoBbg
        drawings.NameLabel = nameLabel
        drawings.DistLabel = distLabel
        drawings.HpBg = hpBg
        drawings.HpFill = hpFill
    end)

    -- 3. Drawing API Tracer Line
    pcall(function()
        if Drawing and Drawing.new then
            local tr = Drawing.new("Line")
            tr.Visible = false
            tr.Thickness = 1
            drawings.Tracer = tr
        end
    end)

    ESP_Cache[player] = drawings
end

local function removeESP(player)
    local data = ESP_Cache[player]
    if data then
        hideDrawing(data)
        if data.BoxBillboard then
            pcall(function() data.BoxBillboard:Destroy() end)
        end
        if data.InfoBillboard then
            pcall(function() data.InfoBillboard:Destroy() end)
        end
        if data.Highlight then
            pcall(function() data.Highlight:Destroy() end)
        end
        for name, item in pairs(data) do
            if typeof(item) == "table" and item.Remove then
                pcall(function() item:Remove() end)
            end
        end
        ESP_Cache[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createESP(p)
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- ========================================================
-- ITEM ESP ENGINE
-- ========================================================
local Item_ESP_Cache = {}

local function getLootPosition(item)
    if not item then return nil end
    local ok, piv = pcall(function() return item:GetPivot().Position end)
    if ok and piv then return piv end
    if item:IsA("Model") then
        local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
        return primary and primary.Position
    elseif item:IsA("BasePart") then
        return item.Position
    end
    return nil
end

local function removeItemESP(item)
    local data = Item_ESP_Cache[item]
    if data then
        pcall(function()
            if typeof(data) == "table" then
                if data.Gui then
                    data.Gui:Destroy()
                end
                if data.Highlight then
                    data.Highlight:Destroy()
                end
                if data.Remove then
                    data:Remove()
                end
            elseif typeof(data) == "userdata" and data.Remove then
                data:Remove()
            end
        end)
        Item_ESP_Cache[item] = nil
    end
end

local WarzLootFolder = workspace:FindFirstChild("WarzLoot")
if WarzLootFolder then
    WarzLootFolder.ChildRemoved:Connect(removeItemESP)
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == "WarzLoot" then
        WarzLootFolder = child
        child.ChildRemoved:Connect(removeItemESP)
    end
end)

-- ========================================================
-- ========================================================
-- AIMBOT & FOV CIRCLE (HYBRID NATIVE GUI + DRAWING API)
-- ========================================================
local FOVScreenGui = nil
local FOVCircleFrame = nil
local FOVCircleStroke = nil
local FOVCircleDrawing = nil

-- 1. Drawing API Circle (Fallback / primary if supported by executor)
pcall(function()
    if Drawing and Drawing.new then
        local c = Drawing.new("Circle")
        c.Visible = false
        c.Radius = Combat_Config.FOVRadius or 150
        c.Color = Combat_Config.FOVColor or Color3.fromRGB(255, 255, 255)
        c.Thickness = 1.5
        c.Filled = false
        FOVCircleDrawing = c
    end
end)

-- 2. Native Roblox ScreenGui Circle (Guaranteed rendering on client)
local function getSafeGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    return pGui
end

local function setupFOVScreenGui()
    if FOVScreenGui and FOVScreenGui.Parent and FOVCircleFrame and FOVCircleStroke then
        return
    end

    pcall(function()
        if FOVScreenGui then FOVScreenGui:Destroy() end
    end)

    pcall(function()
        local parentTarget = getSafeGuiParent()
        local sg = Instance.new("ScreenGui")
        sg.Name = "WarZ_Unique_FOV"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999999
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = parentTarget

        local fovFrame = Instance.new("Frame", sg)
        fovFrame.Name = "FOVCircle"
        fovFrame.BackgroundTransparency = 1
        fovFrame.Visible = false
        fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)

        local stroke = Instance.new("UIStroke", fovFrame)
        stroke.Color = Combat_Config.FOVColor or Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local corner = Instance.new("UICorner", fovFrame)
        corner.CornerRadius = UDim.new(1, 0)

        FOVScreenGui = sg
        FOVCircleFrame = fovFrame
        FOVCircleStroke = stroke
    end)
end

setupFOVScreenGui()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupFOVScreenGui()
end)

local aimKey1Held = false
local aimKey2Held = false

local function isKeyMatching(input, keySetting)
    if not keySetting or keySetting == "None" then return false end
    if (keySetting == "Right Click" or keySetting:find("Right Click")) and input.UserInputType == Enum.UserInputType.MouseButton2 then
        return true
    elseif (keySetting == "Left Click" or keySetting:find("Left Click")) and input.UserInputType == Enum.UserInputType.MouseButton1 then
        return true
    elseif keySetting == "Left Alt" and input.KeyCode == Enum.KeyCode.LeftAlt then
        return true
    elseif keySetting == "Left Shift" and input.KeyCode == Enum.KeyCode.LeftShift then
        return true
    elseif keySetting == "E" and input.KeyCode == Enum.KeyCode.E then
        return true
    elseif keySetting == "C" and input.KeyCode == Enum.KeyCode.C then
        return true
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isKeyMatching(input, Combat_Config.AimKey1) then
        aimKey1Held = true
    end
    if isKeyMatching(input, Combat_Config.AimKey2) then
        aimKey2Held = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isKeyMatching(input, Combat_Config.AimKey1) then
        aimKey1Held = false
    end
    if isKeyMatching(input, Combat_Config.AimKey2) then
        aimKey2Held = false
    end
end)

local function isKeyActive(keySetting, heldFlag)
    if not keySetting or keySetting == "None" then return false end
    if keySetting == "Always Active" then return true end

    local myChar = LocalPlayer.Character
    if keySetting == "Right Click" or keySetting:find("Right Click") then
        return heldFlag 
            or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            or (myChar and myChar:GetAttribute("WarzAim") == true)
    elseif keySetting == "Left Click" or keySetting:find("Left Click") then
        return heldFlag or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif keySetting == "Left Alt" then
        return heldFlag or UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
    elseif keySetting == "Left Shift" then
        return heldFlag or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    elseif keySetting == "E" then
        return heldFlag or UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif keySetting == "C" then
        return heldFlag or UserInputService:IsKeyDown(Enum.KeyCode.C)
    end
    return false
end

local function isAimKeyDown()
    if not Combat_Config.AimbotEnabled then return false end
    if Combat_Config.AimKey1 == "Always Active" or Combat_Config.AimKey2 == "Always Active" then
        return true
    end
    local active1 = isKeyActive(Combat_Config.AimKey1, aimKey1Held)
    local active2 = isKeyActive(Combat_Config.AimKey2, aimKey2Held)
    return active1 or active2
end

-- Ensure map geometry has CanQuery enabled so raycasts never phase through walls/buildings
task.spawn(function()
    while true do
        pcall(function()
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name:find("Map") or child.Name:find("Level") or child.Name:find("Barricade") or child.Name == "Targets" then
                    for _, part in ipairs(child:GetDescendants()) do
                        if part:IsA("BasePart") and not part.CanQuery and not part:IsDescendantOf(LocalPlayer.Character) then
                            part.CanQuery = true
                        end
                    end
                end
            end
        end)
        task.wait(4)
    end
end)

local function isSingleRayClear(fromPos, toPos, targetChar)
    local dir = toPos - fromPos
    local totalDist = dir.Magnitude
    if totalDist < 0.25 then return true end

    local dirUnit = dir.Unit
    local curOrigin = fromPos
    local remDist = totalDist

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    local myChar = LocalPlayer.Character
    local ignoreList = {
        myChar,
        workspace:FindFirstChild("WarzFx"),
        workspace:FindFirstChild("WarzLoot"),
        workspace:FindFirstChild("Body")
    }

    for _ = 1, 6 do
        rayParams.FilterDescendantsInstances = ignoreList
        local hit = workspace:Raycast(curOrigin, dirUnit * remDist, rayParams)
        if not hit then
            return true
        end

        local hitPart = hit.Instance
        if targetChar and hitPart:IsDescendantOf(targetChar) then
            return true
        end

        local isIgnorable = false
        if hitPart:IsA("BasePart") then
            local nLow = hitPart.Name:lower()
            -- Viewmodel / Camera near-plane overlay part right at origin
            if (hit.Position - fromPos).Magnitude < 0.8 then
                isIgnorable = true
            -- Pure invisible trigger zones (sound zones, touch interests, checkpoints)
            elseif (hitPart.Transparency >= 0.98 and not hitPart.CanCollide and not nLow:find("vox") and not nLow:find("wall") and not nLow:find("shield")) then
                isIgnorable = true
            elseif nLow:find("trigger") or nLow:find("touchinterest") or nLow:find("audiozone") then
                isIgnorable = true
            end
        end

        if isIgnorable then
            table.insert(ignoreList, hitPart)
            local adv = (hit.Position - curOrigin).Magnitude + 0.1
            if adv >= remDist then
                return true
            end
            curOrigin = curOrigin + dirUnit * adv
            remDist = remDist - adv
        else
            -- Real wall, building, fence, barricade, car, tree, etc.
            return false
        end
    end

    return false
end

-- Robust dual-origin line-of-sight raycast (Camera + Character weapon angle)
local function isTargetVisible(targetPart, targetChar)
    local cam = workspace.CurrentCamera
    if not cam or not targetPart or not targetChar then return false end

    local targetPos = targetPart.Position
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHead = myChar and myChar:FindFirstChild("Head")
    local myOrigin = myHead and myHead.Position or (myHRP and myHRP.Position + Vector3.new(0, 1.5, 0))
    local camOrigin = cam.CFrame.Position

    -- 1. Check Camera Line of Sight
    local camClear = isSingleRayClear(camOrigin, targetPos, targetChar)
    if not camClear then
        return false -- Blocked from camera view
    end

    -- 2. Check Character Line of Sight (Where gun fires in 3rd person)
    if myOrigin then
        local charClear = isSingleRayClear(myOrigin, targetPos, targetChar)
        if not charClear then
            return false -- Blocked from character weapon / chest angle
        end
    end

    return true
end

local function getClosestPlayerToCenter(screenCenter)
    local closestPlayer = nil
    local shortestDist = Combat_Config.FOVRadius
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local myChar = LocalPlayer.Character
    if not myChar or myChar:GetAttribute("WarzDead") == true or LocalPlayer:GetAttribute("CSGO_Dead") == true then
        return nil
    end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent == Players then
            if not isTeammate(player) then
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local targetPart = getPlayerAimPart(player, Combat_Config.AimbotPart)
                local hrp = targetPart or (char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart))

                -- Check alive state strictly
                local isAlive = char 
                    and targetPart 
                    and (not hum or hum.Health > 0)
                    and char:GetAttribute("WarzDead") ~= true
                    and player:GetAttribute("CSGO_Dead") ~= true
                    and char:IsDescendantOf(workspace)

                if isAlive then
                    local dist3D = (myHRP.Position - targetPart.Position).Magnitude
                    if dist3D <= Combat_Config.MaxAimbotDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and screenPos.Z > 0 then
                            local canSee = true
                            if Combat_Config.WallCheck then
                                canSee = isTargetVisible(targetPart, char)
                            end

                            if canSee then
                                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if dist2D <= shortestDist then
                                    shortestDist = dist2D
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ========================================================
-- WEAPON AUTO SWITCH BACK TRACKER
-- ========================================================
local lastHeldWeaponSlot = 1

local function updateHeldWeapon()
    local cur = tonumber(LocalPlayer:GetAttribute("CSGO_ActiveSlot"))
    if cur == 1 or cur == 2 then
        lastHeldWeaponSlot = cur
    end
end

LocalPlayer:GetAttributeChangedSignal("CSGO_ActiveSlot"):Connect(updateHeldWeapon)
updateHeldWeapon()

local function switchBackToGun()
    task.wait(0.05)
    local cur = tonumber(LocalPlayer:GetAttribute("CSGO_ActiveSlot"))
    if cur ~= 1 and cur ~= 2 then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local switchRemote = remotes and remotes:FindFirstChild("SwitchWeaponRequest")
        if switchRemote then
            switchRemote:FireServer(lastHeldWeaponSlot or 1)
        end
    end
end

local isHealingActive = false
LocalPlayer:GetAttributeChangedSignal("WarzMedCdLeft"):Connect(function()
    local cd = tonumber(LocalPlayer:GetAttribute("WarzMedCdLeft")) or 0
    if cd > 0.05 then
        isHealingActive = true
    elseif isHealingActive and cd <= 0.05 then
        isHealingActive = false
        switchBackToGun()
    end
end)

local function triggerAutoSwitchBack()
    task.spawn(function()
        local t0 = tick()
        -- Wait up to 0.6s for healing cooldown to start
        while tick() - t0 < 0.6 do
            if (tonumber(LocalPlayer:GetAttribute("WarzMedCdLeft")) or 0) > 0.05 then
                break
            end
            task.wait(0.05)
        end
        -- Wait until healing cooldown finishes or max 4s timeout
        while (tonumber(LocalPlayer:GetAttribute("WarzMedCdLeft")) or 0) > 0.05 and (tick() - t0 < 4.0) do
            task.wait(0.05)
        end
        switchBackToGun()
    end)
end

-- ========================================================
-- NO MUZZLE FLASH HOOK (COMPLETELY ELIMINATE FLASHES WHILE PRESERVING BULLET TRACERS)
-- ========================================================
local function isTracerOrBullet(inst)
    if not inst then return false end
    local n = inst.Name:lower()
    if n:find("tracer") or n:find("bullet") or n:find("trail") or n:find("shot") or n:find("proj") or n:find("beam") or n:find("line") or n:find("laser") then
        return true
    end
    if inst:IsA("Beam") or inst:IsA("Trail") then
        return true
    end
    return false
end

local function enhanceBulletTracer(inst)
    if not Combat_Config.BulletTracers or not inst then return end
    pcall(function()
        if inst:IsA("Beam") then
            inst.Enabled = true
            inst.Transparency = NumberSequence.new(0)
            if inst.Width0 < 0.15 then inst.Width0 = 0.22 end
            if inst.Width1 < 0.15 then inst.Width1 = 0.22 end
            inst.FaceCamera = true
        elseif inst:IsA("Trail") then
            inst.Enabled = true
            inst.Transparency = NumberSequence.new(0)
            if inst.Lifetime < 0.3 then inst.Lifetime = 0.6 end
            inst.FaceCamera = true
        elseif inst:IsA("BasePart") and isTracerOrBullet(inst) then
            inst.Transparency = 0
        end
    end)
end

local function neutraliseFlashInstance(inst)
    if not Combat_Config.NoMuzzleFlash or not inst then return end
    -- ห้ามปิดกั้นหรือซ่อนเส้นกระสุนเด็ดขาด เพื่อให้มองเห็นทิศทางกระสุนและคุมปืนได้
    if isTracerOrBullet(inst) then
        enhanceBulletTracer(inst)
        return
    end

    pcall(function()
        local n = inst.Name:lower()
        if inst:IsA("Light") then
            inst.Enabled = false
            inst.Brightness = 0
            inst.Range = 0
        elseif inst:IsA("BillboardGui") then
            if n:find("flash") or n:find("muzzle") or n:find("fire") or n:find("glow") or n:find("light") or n:find("spark") then
                inst.Enabled = false
                inst.Size = UDim2.new(0, 0, 0, 0)
                inst.AlwaysOnTop = false
            end
        elseif inst:IsA("ParticleEmitter") then
            if n:find("flash") or n:find("muzzle") or n:find("fire") or n:find("spark") or n:find("smoke") or n:find("circle") then
                inst.Enabled = false
                inst.Rate = 0
                inst.Transparency = NumberSequence.new(1)
                inst.Size = NumberSequence.new(0)
                inst.Texture = ""
                inst:Clear()
            end
        end
    end)
end

local function cleanMuzzleHierarchy(root)
    if not Combat_Config.NoMuzzleFlash or not root then return end
    if isTracerOrBullet(root) then
        enhanceBulletTracer(root)
        return
    end
    neutraliseFlashInstance(root)
    for _, d in ipairs(root:GetDescendants()) do
        if isTracerOrBullet(d) then
            enhanceBulletTracer(d)
        else
            neutraliseFlashInstance(d)
        end
    end
end

-- 1. Camera Viewmodel Flash Neutralizer (Extinguishes 100% of 1st-person screen flashes)
local function handleCameraDescendant(d)
    if not Combat_Config.NoMuzzleFlash then return end
    if isTracerOrBullet(d) then
        enhanceBulletTracer(d)
        return
    end
    local n = d.Name:lower()
    if d:IsA("Light") or d:IsA("BillboardGui") then
        neutraliseFlashInstance(d)
    elseif d:IsA("ParticleEmitter") then
        if n:find("flash") or n:find("muzzle") or n:find("fire") or n:find("spark") or n:find("smoke") or n:find("circle") then
            neutraliseFlashInstance(d)
        end
    elseif n:find("flash") or n:find("muzzle") or n:find("fire") or n:find("light") or n:find("spark") or n:find("smoke") or n:find("circle") or n:find("glow") then
        cleanMuzzleHierarchy(d)
    end
end

if workspace.CurrentCamera then
    workspace.CurrentCamera.DescendantAdded:Connect(handleCameraDescendant)
    for _, d in ipairs(workspace.CurrentCamera:GetDescendants()) do
        handleCameraDescendant(d)
    end
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local cam = workspace.CurrentCamera
    if cam then
        cam.DescendantAdded:Connect(handleCameraDescendant)
        for _, d in ipairs(cam:GetDescendants()) do
            handleCameraDescendant(d)
        end
    end
end)

-- 2. Character Gun Muzzle Neutralizer (Extinguishes 3rd-person gun barrel flashes)
local function handleCharDescendant(d)
    if not Combat_Config.NoMuzzleFlash then return end
    if isTracerOrBullet(d) then
        enhanceBulletTracer(d)
        return
    end
    local n = d.Name:lower()
    if d:IsA("Light") or n:find("muzzle") or n:find("flash") or n:find("light") or n:find("fire") or n:find("glow") then
        cleanMuzzleHierarchy(d)
    end
end

local function hookCharFlash(char)
    if not char then return end
    char.DescendantAdded:Connect(handleCharDescendant)
    for _, d in ipairs(char:GetDescendants()) do
        handleCharDescendant(d)
    end
end

if LocalPlayer.Character then
    hookCharFlash(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(hookCharFlash)

-- 3. WarzFx Folder Listener (Preserves bullet tracers 100% while silencing barrel flashes)
local WarzFxFolder = workspace:FindFirstChild("WarzFx")
local function suppressFxMuzzle(fx)
    if not fx then return end
    if isTracerOrBullet(fx) then
        enhanceBulletTracer(fx)
        for _, d in ipairs(fx:GetDescendants()) do
            if isTracerOrBullet(d) then
                enhanceBulletTracer(d)
            end
        end
        return
    end

    if not Combat_Config.NoMuzzleFlash then return end

    pcall(function()
        local n = fx.Name:lower()
        if n:find("muzzle") or n:find("flash") or n:find("light") or n:find("fire") or n:find("spark") then
            if fx:IsA("BasePart") then
                fx.Transparency = 1
            end
            cleanMuzzleHierarchy(fx)
        end
    end)
end

if WarzFxFolder then
    WarzFxFolder.ChildAdded:Connect(suppressFxMuzzle)
    for _, c in ipairs(WarzFxFolder:GetChildren()) do
        suppressFxMuzzle(c)
    end
end
workspace.ChildAdded:Connect(function(c)
    if c.Name == "WarzFx" then
        WarzFxFolder = c
        c.ChildAdded:Connect(suppressFxMuzzle)
    end
end)

-- 4. Deep Module Hook for CombatFx & FpsView
local function findAnyModule(name)
    local getlm = getloadedmodules or (syn and syn.getloadedmodules)
    if getlm then
        for _, m in ipairs(getlm()) do
            if m.Name == name then
                local ok, res = pcall(require, m)
                if ok and type(res) == "table" then return res end
            end
        end
    end
    if LocalPlayer:FindFirstChild("PlayerScripts") then
        local found = LocalPlayer.PlayerScripts:FindFirstChild(name, true)
        if found and found:IsA("ModuleScript") then
            local ok, res = pcall(require, found)
            if ok and type(res) == "table" then return res end
        end
    end
    if ReplicatedStorage then
        local found = ReplicatedStorage:FindFirstChild(name, true)
        if found and found:IsA("ModuleScript") then
            local ok, res = pcall(require, found)
            if ok and type(res) == "table" then return res end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        pcall(function()
            -- Hook CombatFx
            local cfxMod = findAnyModule("CombatFx")
            if cfxMod and not cfxMod._WarzHubMuzzleHooked then
                cfxMod._WarzHubMuzzleHooked = true
                if type(cfxMod.MuzzleFlash) == "function" then
                    local origMuzzle = cfxMod.MuzzleFlash
                    cfxMod.MuzzleFlash = function(pos, dir, ...)
                        if Combat_Config.NoMuzzleFlash then
                            return
                        end
                        return origMuzzle(pos, dir, ...)
                    end
                end
            end

            -- Hook FpsView
            local fpsMod = findAnyModule("FpsView")
            if fpsMod and not fpsMod._WarzHubFpsHooked then
                fpsMod._WarzHubFpsHooked = true
                if type(fpsMod.PlayShoot) == "function" then
                    local origFpsShoot = fpsMod.PlayShoot
                    fpsMod.PlayShoot = function(...)
                        local res = origFpsShoot(...)
                        if Combat_Config.NoMuzzleFlash and workspace.CurrentCamera then
                            for _, d in ipairs(workspace.CurrentCamera:GetDescendants()) do
                                if d:IsA("Light") or d:IsA("ParticleEmitter") or d:IsA("BillboardGui") then
                                    neutraliseFlashInstance(d)
                                end
                            end
                        end
                        return res
                    end
                end
            end
        end)
        task.wait(2)
    end
end)

-- ========================================================
-- AUTO MED 3 3 1 ENGINE (PUMP MEDS UNTIL 100% HP & AUTO RETURN TO GUN)
-- ========================================================
local lastMedUsedTick = 0
local isAutoMedLoopRunning = false
local VirtualInputManager = game:GetService("VirtualInputManager")

local function pressKey(keyCode, byteCode)
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end
    end)
    pcall(function()
        if keyclick then
            keyclick(byteCode)
        elseif keypress and keyrelease then
            keypress(byteCode)
            task.wait(0.02)
            keyrelease(byteCode)
        end
    end)
end

local function switchToGunDirect()
    pcall(function()
        pressKey(Enum.KeyCode.One, 0x31)
    end)
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local switchRemote = remotes and remotes:FindFirstChild("SwitchWeaponRequest")
        if switchRemote then
            switchRemote:FireServer(lastHeldWeaponSlot or 1)
        end
    end)
end

local function performMed331Cycle()
    local kd = math.clamp(tonumber(Med_Config.KeyDelay) or 0.08, 0.02, 0.5)

    -- 1. กดปุ่ม 3 (สลับไปถือยาในช่อง 3)
    pressKey(Enum.KeyCode.Three, 0x33)
    task.wait(kd)

    -- 2. กดปุ่ม 3 ซ้ำอีกครั้ง (กดยาเพื่อปั้ม)
    pressKey(Enum.KeyCode.Three, 0x33)
    task.wait(kd + 0.04)

    -- 3. กดปุ่ม 1 (สลับกลับมาถือปืนหลักในช่อง 1 ทันที เพื่อยกเลิกอนิเมชั่นและพร้อมยิง)
    pressKey(Enum.KeyCode.One, 0x31)

    -- สลับกลับมาถือปืนผ่าน Remote เพื่อความแน่นอน 100%
    pcall(function()
        task.wait(0.04)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local switchRemote = remotes and remotes:FindFirstChild("SwitchWeaponRequest")
        if switchRemote then
            switchRemote:FireServer(lastHeldWeaponSlot or 1)
        end
    end)
end

local function startAutoMed331Loop()
    if isAutoMedLoopRunning then return end
    isAutoMedLoopRunning = true

    task.spawn(function()
        local loopStart = tick()
        local maxWaitTimeout = 30 -- ป้องกันค้างไม่เกิน 30 วินาที

        while Med_Config.Enabled and (tick() - loopStart < maxWaitTimeout) do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local isAlive = char and hum and hum.Health > 0 and char:GetAttribute("WarzDead") ~= true and LocalPlayer:GetAttribute("CSGO_Dead") ~= true

            if not isAlive or hum.MaxHealth <= 0 then
                break
            end

            -- ตรวจสอบว่าเลือดกลับมาเต็ม 100% แล้วหรือยัง (ตั้งแต่ 99.5% ขึ้นไป)
            local currentHpPercent = (hum.Health / hum.MaxHealth) * 100
            if currentHpPercent >= 99.5 then
                break
            end

            local gameCd = tonumber(LocalPlayer:GetAttribute("WarzMedCdLeft")) or 0
            if gameCd <= 0.05 then
                performMed331Cycle()
                lastMedUsedTick = tick()

                -- รอให้เกมเริ่มคูลดาวน์ยาหรือรอรอบเวลาที่ตั้งไว้
                local delayWait = math.max(0.1, tonumber(Med_Config.Delay) or 0.8)
                local cdStart = tick()
                while tick() - cdStart < delayWait do
                    local cdLeft = tonumber(LocalPlayer:GetAttribute("WarzMedCdLeft")) or 0
                    if cdLeft > 0.05 then
                        -- กำลังติดคูลดาวน์ รอจนกว่าคูลดาวน์จะหมด
                        while (tonumber(LocalPlayer:GetAttribute("WarzMedCdLeft")) or 0) > 0.05 and (tick() - cdStart < 3.5) do
                            task.wait(0.05)
                        end
                        break
                    end
                    task.wait(0.05)
                end
            else
                task.wait(0.05)
            end
            task.wait(0.05)
        end

        -- เมื่อปั้มยาเสร็จ (เลือดกลับมาเต็ม 100%) ให้สลับกลับมาถือปืนอัตโนมัติแน่นอน 100%
        task.wait(0.05)
        switchToGunDirect()

        isAutoMedLoopRunning = false
    end)
end

task.spawn(function()
    while true do
        task.wait(0.06)
        if Med_Config.Enabled and not isAutoMedLoopRunning then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local isAlive = char and hum and hum.Health > 0 and char:GetAttribute("WarzDead") ~= true and LocalPlayer:GetAttribute("CSGO_Dead") ~= true

            if isAlive and hum.MaxHealth > 0 then
                local currentHpPercent = (hum.Health / hum.MaxHealth) * 100
                local healthLost = 100 - currentHpPercent

                -- ตรวจสอบว่าเลือดลดลงไปเกินกว่า % ที่ตั้งไว้ (ค่าเริ่มต้น 10%)
                if healthLost >= Med_Config.HealthLossPercent then
                    startAutoMed331Loop()
                end
            end
        end
    end
end)

-- ========================================================
-- ========================================================
-- AUTO LOOT THREAD (LOOT AURA - HYBRID PROMPT & REMOTE ENGINE)
-- ========================================================
local function extractUid(item)
    if not item then return nil end
    local uid = item:GetAttribute("LootUid")
        or item:GetAttribute("Uid")
        or item:GetAttribute("ID")
        or item:GetAttribute("DropId")
        or item:GetAttribute("ItemId")
    if uid then return uid end

    for _, name in ipairs({"LootUid", "Uid", "ID", "DropId", "ItemId"}) do
        local child = item:FindFirstChild(name)
        if child and child:IsA("ValueBase") then
            return child.Value
        end
    end

    for _, d in ipairs(item:GetDescendants()) do
        uid = d:GetAttribute("LootUid")
            or d:GetAttribute("Uid")
            or d:GetAttribute("ID")
            or d:GetAttribute("DropId")
            or d:GetAttribute("ItemId")
        if uid then return uid end
        for _, name in ipairs({"LootUid", "Uid", "ID", "DropId", "ItemId"}) do
            local child = d:FindFirstChild(name)
            if child and child:IsA("ValueBase") then
                return child.Value
            end
        end
    end
    return nil
end

local function getPickupRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    local p = remotes:FindFirstChild("PickupLoot")
        or remotes:FindFirstChild("PickupItem")
        or remotes:FindFirstChild("LootItem")
        or remotes:FindFirstChild("Pickup")
        or remotes:FindFirstChild("TakeItem")
    if p then return p end
    for _, d in ipairs(remotes:GetDescendants()) do
        if d:IsA("RemoteEvent") then
            local low = d.Name:lower()
            if low:find("pickup") or low:find("loot") then
                return d
            end
        end
    end
    return nil
end

local cachedDiscoveredItems = {}
local lastDiscoveryScan = 0

local function getDiscoveredItems()
    local now = os.clock()
    if now - lastDiscoveryScan < 0.1 and #cachedDiscoveredItems > 0 then
        return cachedDiscoveredItems
    end
    lastDiscoveryScan = now

    local discovered = {}
    local seen = {}

    local function recordItem(inst, name, pos, part, prompt)
        if not inst or seen[inst] then return end
        seen[inst] = true
        table.insert(discovered, {
            Instance = inst,
            Name = name or inst.Name,
            Position = pos,
            Part = part,
            Prompt = prompt
        })
    end

    -- 1. Direct Scan of WarzLoot (The native loot folder in this game!)
    local warzLoot = workspace:FindFirstChild("WarzLoot")
    if warzLoot then
        for _, item in ipairs(warzLoot:GetChildren()) do
            local pos = getLootPosition(item)
            local part = (item:IsA("BasePart") and item) or item:FindFirstChildWhichIsA("BasePart", true)
            local n = item:GetAttribute("LootName") or item:GetAttribute("LootItemId") or item.Name
            if pos and part then
                recordItem(item, n, pos, part, nil)
            end
        end
    end

    -- 2. Scan other common loot folders
    local otherFolders = {"Loot", "Drops", "Items", "DroppedItems", "Drop", "WorldLoot"}
    for _, fName in ipairs(otherFolders) do
        local f = workspace:FindFirstChild(fName)
        if f then
            for _, item in ipairs(f:GetChildren()) do
                local pos = getLootPosition(item)
                local part = (item:IsA("BasePart") and item) or item:FindFirstChildWhichIsA("BasePart", true)
                local n = item:GetAttribute("LootName") or item:GetAttribute("LootItemId") or item.Name
                if pos and part then
                    recordItem(item, n, pos, part, nil)
                end
            end
        end
    end

    -- 3. Scan workspace root items with Loot attributes
    for _, child in ipairs(workspace:GetChildren()) do
        if (child:IsA("Model") or child:IsA("BasePart")) and child.Name ~= "Terrain" and child.Name ~= "Camera" and not child:FindFirstChildOfClass("Humanoid") then
            local uid = child:GetAttribute("LootUid") or child:GetAttribute("LootItemId") or child:GetAttribute("LootName")
            if uid then
                local pos = getLootPosition(child)
                local part = (child:IsA("BasePart") and child) or child:FindFirstChildWhichIsA("BasePart", true)
                local n = child:GetAttribute("LootName") or child:GetAttribute("LootItemId") or child.Name
                if pos and part then
                    recordItem(child, n, pos, part, nil)
                end
            end
        end
    end

    cachedDiscoveredItems = discovered
    return discovered
end

local function pickupSingleItem(item, uid, myHRP, directPrompt)
    if not item then return end
    local holdTime = math.clamp(tonumber(Item_Config.AutoLootHoldTime) or 1.1, 0.3, 3.0)

    -- Method 1: RemoteEvent (WarZ native PickupLoot protocol: prep -> hold -> use)
    local pickupRemote = getPickupRemote()
    if pickupRemote and uid then
        pcall(function() pickupRemote:FireServer(uid, "prep", 1) end)
    end

    -- Method 2: Native WarZ Client LootPickup module hook (hold begin)
    pcall(function()
        local client = LocalPlayer.PlayerScripts:FindFirstChild("Client")
        local world = client and client:FindFirstChild("world")
        local lpMod = world and world:FindFirstChild("LootPickup")
        if lpMod then
            local mod = require(lpMod)
            if mod and mod.SetTouchHeld then
                mod.SetTouchHeld(true)
            end
        end
    end)

    -- Method 3: Simulate keypress E via VirtualInputManager
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        end
    end)

    -- Method 4: ProximityPrompt fallback if present
    local prompt = directPrompt or (item:IsA("ProximityPrompt") and item) or item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        pcall(function()
            prompt.Enabled = true
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 9999
            prompt.HoldDuration = 0
            if fireproximityprompt then
                fireproximityprompt(prompt, 0)
                fireproximityprompt(prompt)
            end
        end)
    end

    -- Method 5: ClickDetector trigger
    for _, d in ipairs(item:GetDescendants()) do
        if d:IsA("ClickDetector") then
            pcall(function()
                d.MaxActivationDistance = 9999
                if fireclickdetector then
                    fireclickdetector(d)
                end
            end)
        end
    end

    -- Hold for full duration so the circle fills 100%!
    task.wait(holdTime)

    -- Finish pickup: commit "use"
    if pickupRemote and uid then
        pcall(function() pickupRemote:FireServer(uid, "use", 1) end)
        pcall(function() pickupRemote:FireServer(uid) end)
        pcall(function() pickupRemote:FireServer(tostring(uid)) end)
    end

    -- Release inputs
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end)
    pcall(function()
        local client = LocalPlayer.PlayerScripts:FindFirstChild("Client")
        local world = client and client:FindFirstChild("world")
        local lpMod = world and world:FindFirstChild("LootPickup")
        if lpMod then
            local mod = require(lpMod)
            if mod and mod.SetTouchHeld then
                mod.SetTouchHeld(false)
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(math.max(0.05, tonumber(Item_Config.AutoLootDelay) or 0.15))
        if Item_Config.AutoLootEnabled then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart or myChar:FindFirstChild("Torso"))
            local myPos = (myHRP and myHRP.Position) or (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position)

            if myPos then
                local discoveredItems = getDiscoveredItems()
                local maxRadius = math.max(5, tonumber(Item_Config.AutoLootRadius) or 25)

                for _, data in ipairs(discoveredItems) do
                    if not Item_Config.AutoLootEnabled then break end

                    local pos = data.Position
                    if pos then
                        local dist = (pos - myPos).Magnitude
                        if dist <= maxRadius then
                            local item = data.Instance
                            local name = data.Name
                            local uid = extractUid(item)
                            local itemId = item:GetAttribute("LootItemId") or name
                            local cat, _ = getItemCategory(itemId)

                            local canLoot = true
                            if Item_Config.AutoLootFilterOnly then
                                canLoot = shouldDisplayItem(name, itemId, cat)
                            end

                            if canLoot then
                                task.spawn(function()
                                    pickupSingleItem(item, uid, myHRP, data.Prompt)
                                end)
                                task.wait(math.max(0.04, tonumber(Item_Config.AutoLootDelay) or 0.15))
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ========================================================
-- MAIN RENDER STEPPED (AIMBOT, ESP & ITEMS)
-- ========================================================
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end

    -- 0. INSTANT MUZZLE FLASH SUPPRESSION (Kill any viewmodel flash every frame)
    if Combat_Config.NoMuzzleFlash then
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                for _, sub in ipairs(child:GetDescendants()) do
                    if sub:IsA("Light") then
                        sub.Enabled = false
                        sub.Brightness = 0
                        sub.Range = 0
                    elseif sub:IsA("BillboardGui") then
                        sub.Enabled = false
                        sub.Size = UDim2.new(0, 0, 0, 0)
                    elseif sub:IsA("ParticleEmitter") then
                        local sName = sub.Name:lower()
                        if sName:find("flash") or sName:find("muzzle") or sName:find("fire") or sName:find("spark") or sName:find("smoke") or sName:find("circle") then
                            sub.Enabled = false
                            sub.Rate = 0
                            sub.Transparency = NumberSequence.new(1)
                            sub.Size = NumberSequence.new(0)
                            sub.Texture = ""
                            sub:Clear()
                        end
                    end
                end
            end
        end
    end

    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- 1. FOV CIRCLE UPDATE (Hybrid ScreenGui + Drawing Circle, always visible when ShowFOVCircle is true)
    pcall(function()
        if Combat_Config.ShowFOVCircle then
            local radius = math.max(10, tonumber(Combat_Config.FOVRadius) or 150)
            local col = Combat_Config.FOVColor or Color3.fromRGB(255, 255, 255)

            -- Update Drawing Circle
            if FOVCircleDrawing then
                FOVCircleDrawing.Visible = true
                FOVCircleDrawing.Position = screenCenter
                FOVCircleDrawing.Radius = radius
                FOVCircleDrawing.Color = col
            end

            -- Update Native ScreenGui Circle
            if not FOVScreenGui or not FOVScreenGui.Parent or not FOVCircleFrame then
                setupFOVScreenGui()
            end

            if FOVCircleFrame then
                FOVCircleFrame.Visible = true
                FOVCircleFrame.Position = UDim2.fromOffset(screenCenter.X, screenCenter.Y)
                FOVCircleFrame.Size = UDim2.fromOffset(radius * 2, radius * 2)
                if FOVCircleStroke then
                    FOVCircleStroke.Color = col
                end
            end
        else
            if FOVCircleDrawing then
                FOVCircleDrawing.Visible = false
            end
            if FOVCircleFrame then
                FOVCircleFrame.Visible = false
            end
        end
    end)

    -- 2. AIMBOT EXECUTION
    pcall(function()
        if Combat_Config.AimbotEnabled and isAimKeyDown() then
            local target = getClosestPlayerToCenter(screenCenter)
            if target then
                local aimPart = getPlayerAimPart(target, Combat_Config.AimbotPart)
                if aimPart then
                    local aimPos = aimPart.Position
                    local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
                    local deltaX = screenPos.X - screenCenter.X
                    local deltaY = screenPos.Y - screenCenter.Y
                    local smoothness = math.max(1, tonumber(Combat_Config.Smoothness) or 5)

                    local vFov = math.rad(Camera.FieldOfView)
                    local hFov = 2 * math.atan(math.tan(vFov / 2) * (viewportSize.X / viewportSize.Y))
                    local radPerPxX = hFov / viewportSize.X
                    local radPerPxY = vFov / viewportSize.Y

                    local cam = resolveWarzCamera()
                    local curYaw = cam and cam.GetYaw and cam.GetYaw()
                    local curPitch = cam and cam.GetPitch and cam.GetPitch()

                    -- Mode 1: Hard Lock (Snaps directly to target)
                    if Combat_Config.AimMode == "Hard Lock" then
                        if onScreen and screenPos.Z > 0 and curYaw and curPitch then
                            setCameraAngles(curYaw - deltaX * radPerPxX, curPitch - deltaY * radPerPxY)
                        else
                            local camPos = Camera.CFrame.Position
                            local toAim = (aimPos - camPos).Unit
                            local targetYaw = math.atan2(-toAim.X, -toAim.Z)
                            local targetPitch = math.asin(math.clamp(toAim.Y, -1, 1))
                            setCameraAngles(targetYaw, targetPitch)
                        end

                    -- Mode 2: Smooth Cam (Smooth angle interpolation)
                    elseif Combat_Config.AimMode == "Smooth Cam" then
                        if onScreen and screenPos.Z > 0 and curYaw and curPitch then
                            local stepYaw = (deltaX * radPerPxX) / smoothness
                            local stepPitch = (deltaY * radPerPxY) / smoothness
                            setCameraAngles(curYaw - stepYaw, curPitch - stepPitch)
                        elseif curYaw and curPitch then
                            local camPos = Camera.CFrame.Position
                            local toAim = (aimPos - camPos).Unit
                            local targetYaw = math.atan2(-toAim.X, -toAim.Z)
                            local targetPitch = math.asin(math.clamp(toAim.Y, -1, 1))
                            local diffYaw = (targetYaw - curYaw + math.pi) % (2 * math.pi) - math.pi
                            local diffPitch = targetPitch - curPitch
                            setCameraAngles(curYaw + diffYaw / smoothness, curPitch + diffPitch / smoothness)
                        end

                    -- Mode 3: Mouse Delta (Pixel offset via mouse mover)
                    elseif Combat_Config.AimMode == "Mouse Delta" then
                        if onScreen and screenPos.Z > 0 and mousemoverel then
                            mousemoverel(deltaX / smoothness, deltaY / smoothness)
                        end
                    end
                end
            end
        end
    end)

    -- 3. PLAYER ESP UPDATE
    pcall(function()
        -- Ensure every player is in ESP cache
        -- Ensure every other player is in ESP cache
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.UserId ~= LocalPlayer.UserId and not ESP_Cache[p] then
                createESP(p)
            end
        end

        local toRemove = {}
        for p, _ in pairs(ESP_Cache) do
            if not p or p == LocalPlayer or p.UserId == LocalPlayer.UserId or not p.Parent or p.Parent ~= Players then
                table.insert(toRemove, p)
            end
        end
        for _, p in ipairs(toRemove) do
            removeESP(p)
        end

        local myPos = (myHRP and myHRP.Position) or (Camera and Camera.CFrame.Position)
        local myChar = LocalPlayer.Character

        for player, esp in pairs(ESP_Cache) do
            if not player or player == LocalPlayer or player.UserId == LocalPlayer.UserId or not player.Parent or player.Parent ~= Players then
                hideDrawing(esp)
                continue
            end

            local char = player.Character
            local liveAim = getPlayerVisualModel(player)
            local targetModel = liveAim or char

            -- STRICT GUARD: Never attach ESP to LocalPlayer's own model
            if not targetModel or targetModel == myChar or (myChar and targetModel:IsDescendantOf(myChar)) then
                hideDrawing(esp)
                continue
            end

            local hrp = (liveAim and (liveAim:FindFirstChild("RootPart") or liveAim:FindFirstChildWhichIsA("BasePart"))) or (char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart))
            local hum = (liveAim and liveAim:FindFirstChildOfClass("Humanoid")) or (char and char:FindFirstChildOfClass("Humanoid"))
            local head = (liveAim and liveAim:FindFirstChild("Head")) or (char and (char:FindFirstChild("Head") or char:FindFirstChild("head") or hrp))

            local isValid = ESP_Config.Enabled 
                and player.Parent == Players 
                and targetModel ~= nil 
                and targetModel:IsDescendantOf(workspace)
                and hrp ~= nil 
                and (not hum or hum.Health > 0)
                and (char == nil or char:GetAttribute("WarzDead") ~= true)
                and player:GetAttribute("CSGO_Dead") ~= true

            if isValid and isTeammate(player) then
                isValid = false
            end

            local dist = 0
            if isValid and myPos and hrp then
                dist = (myPos - hrp.Position).Magnitude
                if dist > ESP_Config.MaxDistance then
                    isValid = false
                end
            end

            if isValid then
                local color = getESPColor(player)

                -- 1. Native Roblox Highlight (Chams) on targetModel
                if ESP_Config.ShowHighlight and targetModel then
                    if not esp.Highlight or esp.Highlight.Parent == nil or esp.Highlight.Adornee ~= targetModel then
                        if esp.Highlight then pcall(function() esp.Highlight:Destroy() end) end
                        local hl = Instance.new("Highlight")
                        hl.Name = "WarZ_ESP_HL"
                        hl.Adornee = targetModel
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        pcall(function() hl.Parent = targetModel end)
                        esp.Highlight = hl
                    end
                    esp.Highlight.Enabled = true
                    esp.Highlight.FillColor = color
                    esp.Highlight.OutlineColor = ESP_Config.HighlightOutline or Color3.fromRGB(255, 255, 255)
                    esp.Highlight.FillTransparency = ESP_Config.HighlightFillTransparency or 0.5
                    esp.Highlight.OutlineTransparency = ESP_Config.HighlightOutlineTransparency or 0
                else
                    if esp.Highlight then esp.Highlight.Enabled = false end
                end

                -- Resolve visual animated positions (head & spine)
                local headPos = nil
                local spinePos = nil

                if targetModel then
                    for _, d in ipairs(targetModel:GetDescendants()) do
                        if d:IsA("Bone") then
                            if not headPos and (d.Name == "Bip01_Head" or d.Name:lower():find("head")) then
                                local ok, cf = pcall(function() return d.TransformedWorldCFrame end)
                                if ok and cf and cf.Position then headPos = cf.Position end
                                if not headPos then
                                    local ok2, wp = pcall(function() return d.WorldPosition end)
                                    if ok2 and wp then headPos = wp end
                                end
                            elseif not spinePos and (d.Name:find("Spine") or d.Name:find("Pelvis") or d.Name:lower():find("torso")) then
                                local ok, cf = pcall(function() return d.TransformedWorldCFrame end)
                                if ok and cf and cf.Position then spinePos = cf.Position end
                                if not spinePos then
                                    local ok2, wp = pcall(function() return d.WorldPosition end)
                                    if ok2 and wp then spinePos = wp end
                                end
                            end
                        end
                        if headPos and spinePos then break end
                    end
                end

                if not headPos and head then headPos = head.Position end
                if not spinePos and hrp then spinePos = hrp.Position end

                local stance = (char and char:GetAttribute("WarzStance"))
                    or (player:GetAttribute("WarzStance"))
                    or (player:GetAttribute("CSGO_Stance"))
                    or (char and char:GetAttribute("CSGO_Stance"))
                    or ""
                local lowStance = string.lower(tostring(stance))
                local isProne = lowStance:find("prone") ~= nil or lowStance:find("lie") ~= nil
                local isCrouching = lowStance:find("crouch") ~= nil

                local diffY = headPos and hrp and (headPos.Y - hrp.Position.Y) or 4.5
                local isRootAtFeet = diffY > 3.0

                if not isProne and not isCrouching and headPos and hrp then
                    if isRootAtFeet then
                        if diffY < 2.2 then
                            isProne = true
                        elseif diffY < 3.6 then
                            isCrouching = true
                        end
                    else
                        if diffY < 0.5 then
                            isProne = true
                        elseif diffY < 1.1 then
                            isCrouching = true
                        end
                    end
                end

                -- 2. Native Roblox 2D Box (BoxBillboard - 100% Locked to 3D character, zero desync)
                if esp.BoxBillboard and hrp then
                    esp.BoxBillboard.Adornee = hrp

                    if isProne then
                        esp.BoxBillboard.Size = UDim2.new(5.6, 0, 2.2, 0)
                        esp.BoxBillboard.StudsOffset = isRootAtFeet and Vector3.new(0, 0.9, 0) or Vector3.new(0, -1.2, 0)
                    elseif isCrouching then
                        esp.BoxBillboard.Size = UDim2.new(3.8, 0, 4.0, 0)
                        esp.BoxBillboard.StudsOffset = isRootAtFeet and Vector3.new(0, 1.8, 0) or Vector3.new(0, -0.4, 0)
                    else
                        -- Standing: Uniform 3.8 x 5.4 studs for every standing player
                        esp.BoxBillboard.Size = UDim2.new(3.8, 0, 5.4, 0)
                        esp.BoxBillboard.StudsOffset = isRootAtFeet and Vector3.new(0, 2.5, 0) or Vector3.new(0, -0.2, 0)
                    end

                    if esp.BoxBillboard.Parent ~= hrp then
                        pcall(function() esp.BoxBillboard.Parent = hrp end)
                    end
                    esp.BoxBillboard.Enabled = ESP_Config.ShowBoxes
                    if esp.BoxStroke then
                        esp.BoxStroke.Color = color
                    end
                end

                -- 3. Native Roblox Info (InfoBillboard - Crisp Name, Distance & Health Bar above head)
                if esp.InfoBillboard and hrp then
                    esp.InfoBillboard.Adornee = hrp

                    local infoY = isRootAtFeet and (isProne and 2.4 or (isCrouching and 4.4 or 5.9)) or (isProne and 0.4 or (isCrouching and 2.2 or 3.2))
                    esp.InfoBillboard.StudsOffset = Vector3.new(0, infoY, 0)

                    if esp.InfoBillboard.Parent ~= hrp then
                        pcall(function() esp.InfoBillboard.Parent = hrp end)
                    end
                    esp.InfoBillboard.Enabled = (ESP_Config.ShowNames or ESP_Config.ShowDistance or ESP_Config.ShowHealth)

                    -- Name
                    if esp.NameLabel then
                        esp.NameLabel.Visible = ESP_Config.ShowNames
                        esp.NameLabel.Text = (player.DisplayName and player.DisplayName ~= "" and player.DisplayName) or player.Name
                        esp.NameLabel.TextSize = ESP_Config.TextSize or 13
                    end

                    -- Distance
                    if esp.DistLabel then
                        esp.DistLabel.Visible = ESP_Config.ShowDistance
                        esp.DistLabel.Text = string.format("[%d m]", math.floor(dist))
                        esp.DistLabel.TextSize = math.max(10, (ESP_Config.TextSize or 13) - 1)
                    end

                    -- Health Bar
                    if esp.HpBg and esp.HpFill then
                        esp.HpBg.Visible = ESP_Config.ShowHealth
                        local curHp = (hum and hum.Health) or 100
                        local maxHp = (hum and math.max(1, hum.MaxHealth)) or 100
                        local healthFrac = math.clamp(curHp / maxHp, 0, 1)
                        esp.HpFill.Size = UDim2.new(healthFrac, 0, 1, 0)
                        esp.HpFill.BackgroundColor3 = Color3.fromRGB(
                            math.floor(255 * (1 - healthFrac)),
                            math.floor(255 * healthFrac),
                            0
                        )
                    end
                end

                -- 4. Drawing Tracer Line (Points to player root if on screen)
                if esp.Tracer then
                    if ESP_Config.ShowTracers and hrp then
                        local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen and rootPos.Z > 0 then
                            esp.Tracer.Visible = true
                            local origin = (ESP_Config.TracerOrigin == "Bottom") and Vector2.new(viewportSize.X / 2, viewportSize.Y) or screenCenter
                            esp.Tracer.From = origin
                            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            esp.Tracer.Color = color
                        else
                            esp.Tracer.Visible = false
                        end
                    else
                        esp.Tracer.Visible = false
                    end
                end
            else
                hideDrawing(esp)
            end
        end
    end)

    -- 4. ITEM ESP & ITEM HIGHLIGHT UPDATE
    pcall(function()
        if Item_Config.ESPEnabled or Item_Config.HighlightEnabled then
            local discoveredItems = getDiscoveredItems()
            local activeSet = {}

            for _, data in ipairs(discoveredItems) do
                local item = data.Instance
                local pos = data.Position
                local part = data.Part
                local name = data.Name
                local dist = myHRP and pos and (pos - myHRP.Position).Magnitude or 0

                if pos and part and dist <= Item_Config.ESPMaxDistance then
                    local itemId = item:GetAttribute("LootItemId") or name
                    local category, catColor = getItemCategory(itemId)

                    if shouldDisplayItem(name, itemId, category) then
                        activeSet[item] = true
                        local espData = Item_ESP_Cache[item]
                        if not espData then
                            espData = { Gui = nil, Label = nil, Part = part, Highlight = nil }
                            Item_ESP_Cache[item] = espData
                        end

                        -- A. Item 2D BillboardGui Text Label
                        if Item_Config.ESPEnabled then
                            if not espData.Gui or espData.Gui.Parent == nil then
                                local bbg = Instance.new("BillboardGui")
                                bbg.Name = "WarZ_Item_ESP"
                                bbg.AlwaysOnTop = true
                                bbg.Size = UDim2.new(0, 160, 0, 24)
                                bbg.StudsOffset = Vector3.new(0, 1.2, 0)
                                bbg.ClipsDescendants = false
                                bbg.Adornee = part
                                bbg.Parent = getSafeGuiParent()

                                local lbl = Instance.new("TextLabel", bbg)
                                lbl.Name = "ItemLabel"
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 1
                                lbl.Text = string.format("%s [%dm]", name, math.floor(dist))
                                lbl.TextColor3 = catColor
                                lbl.TextStrokeTransparency = 0
                                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                lbl.TextSize = Item_Config.TextSize or 13
                                lbl.Font = Enum.Font.SourceSansBold

                                espData.Gui = bbg
                                espData.Label = lbl
                            else
                                espData.Gui.Enabled = true
                                espData.Gui.Adornee = part
                                if espData.Label then
                                    espData.Label.Text = string.format("%s [%dm]", name, math.floor(dist))
                                    espData.Label.TextColor3 = catColor
                                    espData.Label.TextSize = Item_Config.TextSize or 13
                                end
                            end
                        else
                            if espData.Gui then
                                espData.Gui.Enabled = false
                            end
                        end

                        -- B. Item 3D Native Highlight (Chams on Ground Model)
                        if Item_Config.HighlightEnabled then
                            if not espData.Highlight or espData.Highlight.Parent == nil or espData.Highlight.Adornee ~= item then
                                if espData.Highlight then pcall(function() espData.Highlight:Destroy() end) end
                                local hl = Instance.new("Highlight")
                                hl.Name = "WarZ_Item_HL"
                                hl.Adornee = item
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                pcall(function() hl.Parent = item end)
                                espData.Highlight = hl
                            end
                            espData.Highlight.Enabled = true
                            espData.Highlight.FillColor = catColor
                            espData.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            espData.Highlight.FillTransparency = Item_Config.HighlightFillTransparency or 0.4
                            espData.Highlight.OutlineTransparency = Item_Config.HighlightOutlineTransparency or 0
                        else
                            if espData.Highlight then
                                espData.Highlight.Enabled = false
                            end
                        end
                    end
                end
            end

            for item, espData in pairs(Item_ESP_Cache) do
                if not activeSet[item] then
                    if espData.Gui then
                        espData.Gui.Enabled = false
                    end
                    if espData.Highlight then
                        espData.Highlight.Enabled = false
                    end
                end
            end
        else
            for _, espData in pairs(Item_ESP_Cache) do
                if espData.Gui then
                    espData.Gui.Enabled = false
                end
                if espData.Highlight then
                    espData.Highlight.Enabled = false
                end
            end
        end
    end)
end)

-- ========================================================
-- UI CREATION (FLUENT)
-- ========================================================
local Window = Fluent:CreateWindow({
    Title = "Warz By Unique HUB",
    SubTitle = "Visuals, Combat & Items",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})
_G.WarzWindow = Window

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat (ช่วยยิง/ยา)", Icon = "swords" }),
    ESP = Window:AddTab({ Title = "ESP (มองทะลุ)", Icon = "eye" }),
    Items = Window:AddTab({ Title = "Items (ไอเทม)", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Warz By Unique HUB Ready",
        Content = "แก้ปัญหา: วง FOV แสดงผลตลอดเวลา, อัปเกรด Loot Aura 4 รูปแบบดูดของรอบตัว, เปลี่ยนชื่อสคริปต์เรียบร้อย!",
        Duration = 5
    })

    ---------------------------------------------------------
    -- TAB: COMBAT
    ---------------------------------------------------------
    Tabs.Combat:AddParagraph({
        Title = "Aimbot System (ระบบช่วยเล็ง)",
        Content = "Hard Lock (ล็อคตรงจุดเป้า 100%), Smooth Cam (หมุนกล้องสมูทตามค่าที่ตั้ง), Mouse Delta"
    })

    local ToggleAimbot = Tabs.Combat:AddToggle("AimbotMaster", {
        Title = "Enable Aimbot (เปิดระบบช่วยเล็ง)",
        Default = false
    })
    ToggleAimbot:OnChanged(function()
        Combat_Config.AimbotEnabled = Options.AimbotMaster.Value
    end)

    local DropdownAimMode = Tabs.Combat:AddDropdown("AimMode", {
        Title = "Aim Mode (โหมดของ Aimbot)",
        Values = {"Hard Lock", "Smooth Cam", "Mouse Delta"},
        Default = 1,
        Multi = false
    })
    DropdownAimMode:OnChanged(function(val)
        Combat_Config.AimMode = val
    end)

    local DropdownAimKey1 = Tabs.Combat:AddDropdown("AimKey1", {
        Title = "Aim Trigger Key 1 (ปุ่มเล็งที่ 1)",
        Description = "เลือกปุ่มหลักสำหรับล็อคเป้า",
        Values = {"Right Click", "Left Click", "Left Alt", "Left Shift", "E", "C", "Always Active", "None"},
        Default = 1,
        Multi = false
    })
    DropdownAimKey1:OnChanged(function(val)
        Combat_Config.AimKey1 = val
    end)

    local DropdownAimKey2 = Tabs.Combat:AddDropdown("AimKey2", {
        Title = "Aim Trigger Key 2 (ปุ่มเล็งที่ 2 - สำรอง)",
        Description = "เลือกปุ่มที่ 2 เช่น คลิกซ้าย (ไม่ว่าจะกดปุ่มไหนก็ล็อคเป้าทันที)",
        Values = {"Left Click", "Right Click", "Left Alt", "Left Shift", "E", "C", "Always Active", "None"},
        Default = 1,
        Multi = false
    })
    DropdownAimKey2:OnChanged(function(val)
        Combat_Config.AimKey2 = val
    end)

    local TargetPartDropdown = Tabs.Combat:AddDropdown("AimbotPart", {
        Title = "Aim Target Part (จุดที่เล็ง)",
        Values = {"Head", "HumanoidRootPart"},
        Default = 1,
        Multi = false
    })
    TargetPartDropdown:OnChanged(function(val)
        Combat_Config.AimbotPart = val
    end)

    local SliderSmooth = Tabs.Combat:AddSlider("AimbotSmoothness", {
        Title = "Smoothness (ความสมูทในการดูด)",
        Description = "เลข 1 = ล็อคทันที, เลขมาก = สมูทมากดูดช้าลงอย่างเป็นธรรมชาติ",
        Default = 5,
        Min = 1,
        Max = 25,
        Rounding = 0,
        Callback = function(val)
            Combat_Config.Smoothness = val
        end
    })

    local SliderFOV = Tabs.Combat:AddSlider("AimbotFOV", {
        Title = "FOV Radius (รัศมีวงกลมเล็งกลางจอ)",
        Default = 150,
        Min = 50,
        Max = 500,
        Rounding = 0,
        Callback = function(val)
            Combat_Config.FOVRadius = val
        end
    })

    local ToggleFOVCircle = Tabs.Combat:AddToggle("ShowFOVCircle", {
        Title = "Show FOV Circle (แสดงวงกลมเล็งกลางจอ)",
        Default = true
    })
    ToggleFOVCircle:OnChanged(function()
        Combat_Config.ShowFOVCircle = Options.ShowFOVCircle.Value
    end)

    local ToggleWallCheck = Tabs.Combat:AddToggle("WallCheck", {
        Title = "Wall Check (ไม่ล็อคเป้าหลังกำแพง)",
        Default = true
    })
    ToggleWallCheck:OnChanged(function()
        Combat_Config.WallCheck = Options.WallCheck.Value
    end)

    local ToggleNoMuzzleFlash = Tabs.Combat:AddToggle("NoMuzzleFlash", {
        Title = "No Muzzle Flash (ปิดแสงแฟลชปากกระบอกปืน)",
        Description = "ปิดแสงแฟลชและประกายไฟปากกระบอกปืน ไม่แสบตา แต่คงเส้นกระสุน (Bullet Tracer) ไว้ 100% เพื่อให้คุมปืนได้ง่าย",
        Default = true
    })
    ToggleNoMuzzleFlash:OnChanged(function()
        Combat_Config.NoMuzzleFlash = Options.NoMuzzleFlash.Value
    end)

    local ToggleBulletTracers = Tabs.Combat:AddToggle("BulletTracers", {
        Title = "Bullet Tracer Enhancer (คงเส้นกระสุน 100% คุมปืนง่าย)",
        Description = "แสดงและเน้นเส้นกระสุน (Bullet Tracers) ให้เห็นทิศทางกระสุนอย่างชัดเจน ช่วยในการคุมรีคอยล์และดึงเป้า",
        Default = true
    })
    ToggleBulletTracers:OnChanged(function()
        Combat_Config.BulletTracers = Options.BulletTracers.Value
    end)

    local SliderAimbotMaxDist = Tabs.Combat:AddSlider("AimbotMaxDist", {
        Title = "Max Aim Distance (ระยะล็อคสูงสุด)",
        Default = 600,
        Min = 50,
        Max = 1500,
        Rounding = 0,
        Callback = function(val)
            Combat_Config.MaxAimbotDistance = val
        end
    })

    Tabs.Combat:AddParagraph({
        Title = "Auto Meds 3 3 1 (ระบบปั้มยาอัตโนมัติ 3 3 1)",
        Content = "เมื่อเลือดลดลงไปตามที่ตั้ง (ค่าเริ่มต้น 10%) ระบบจะกดปุ่ม [3] -> [3] -> [1] อัตโนมัติวนซ้ำจนกว่าเลือดจะกลับมาเต็ม 100% แล้วสลับกลับมาถือปืนทันที"
    })

    local ToggleAutoMed = Tabs.Combat:AddToggle("AutoMedEnabled", {
        Title = "Enable Auto Meds 3 3 1 (เปิดระบบปั้มยาวนจนเต็ม 100%)",
        Default = false
    })
    ToggleAutoMed:OnChanged(function()
        Med_Config.Enabled = Options.AutoMedEnabled.Value
    end)

    local SliderMedHpLoss = Tabs.Combat:AddSlider("MedHpLoss", {
        Title = "Health Lost Trigger (%) (ใช้ยาเมื่อเลือดลดไปกี่ %)",
        Description = "ค่าเริ่มต้น 10% = เมื่อเลือดลดลงไป 10% (เลือดเหลือต่ำกว่า 90%) จะเริ่มปั้มยาวนจนเต็ม 100% ทันที",
        Default = 10,
        Min = 1,
        Max = 95,
        Rounding = 0,
        Callback = function(val)
            Med_Config.HealthLossPercent = val
        end
    })

    local SliderMedDelay = Tabs.Combat:AddSlider("MedDelay", {
        Title = "Cooldown Delay (ดีเลย์ระหว่างรอบการปั้ม วินาที)",
        Default = 0.8,
        Min = 0.1,
        Max = 5.0,
        Rounding = 1,
        Callback = function(val)
            Med_Config.Delay = val
        end
    })

    local SliderKeyDelay = Tabs.Combat:AddSlider("MedKeyDelay", {
        Title = "3 3 1 Key Delay (ความเร็วการกดปุ่ม วินาที)",
        Description = "ความเร็วในการกดคีย์ 3 -> 3 -> 1 (ค่าน้อย = กดไวมาก)",
        Default = 0.08,
        Min = 0.02,
        Max = 0.3,
        Rounding = 2,
        Callback = function(val)
            Med_Config.KeyDelay = val
        end
    })

    ---------------------------------------------------------
    -- TAB: ESP
    ---------------------------------------------------------
    Tabs.ESP:AddParagraph({
        Title = "Player Visuals (ESP)",
        Content = "มองผู้เล่นทะลุกำแพง พร้อมระบบแยกการทำงานอิสระ ไม่กระตุก ไม่แล็ก"
    })

    local ToggleMaster = Tabs.ESP:AddToggle("ESPMaster", {
        Title = "Enable ESP (เปิดระบบมองทะลุ)",
        Default = true
    })
    ToggleMaster:OnChanged(function(val)
        if val ~= nil then
            ESP_Config.Enabled = val
        elseif Options.ESPMaster then
            ESP_Config.Enabled = Options.ESPMaster.Value
        end
    end)

    local ToggleTeamCheck = Tabs.ESP:AddToggle("TeamCheck", {
        Title = "Team Check (ไม่มองเพื่อนร่วมทีม)",
        Default = false
    })
    ToggleTeamCheck:OnChanged(function()
        ESP_Config.TeamCheck = Options.TeamCheck.Value
    end)

    local ToggleHighlight = Tabs.ESP:AddToggle("ShowHighlight", {
        Title = "Chams / Highlight (ไฮไลท์เรืองแสงรอบตัว)",
        Default = true
    })
    ToggleHighlight:OnChanged(function()
        ESP_Config.ShowHighlight = Options.ShowHighlight.Value
    end)

    local ToggleBoxes = Tabs.ESP:AddToggle("ShowBoxes", {
        Title = "2D Boxes (กรอบสี่เหลี่ยมรอบตัว)",
        Default = true
    })
    ToggleBoxes:OnChanged(function()
        ESP_Config.ShowBoxes = Options.ShowBoxes.Value
    end)

    local ToggleNames = Tabs.ESP:AddToggle("ShowNames", {
        Title = "Player Names (แสดงชื่อผู้เล่น)",
        Default = true
    })
    ToggleNames:OnChanged(function()
        ESP_Config.ShowNames = Options.ShowNames.Value
    end)

    local ToggleHealth = Tabs.ESP:AddToggle("ShowHealth", {
        Title = "Health Bar (หลอดเลือดข้างลำตัว)",
        Default = true
    })
    ToggleHealth:OnChanged(function()
        ESP_Config.ShowHealth = Options.ShowHealth.Value
    end)

    local ToggleDistance = Tabs.ESP:AddToggle("ShowDistance", {
        Title = "Distance (แสดงระยะห่างเมตร)",
        Default = true
    })
    ToggleDistance:OnChanged(function()
        ESP_Config.ShowDistance = Options.ShowDistance.Value
    end)

    local ToggleTracers = Tabs.ESP:AddToggle("ShowTracers", {
        Title = "Tracers (เส้นนำสายตาชี้หาผู้เล่น)",
        Default = false
    })
    ToggleTracers:OnChanged(function()
        ESP_Config.ShowTracers = Options.ShowTracers.Value
    end)

    local TracerOriginDropdown = Tabs.ESP:AddDropdown("TracerOrigin", {
        Title = "Tracer Origin (จุดเริ่มของเส้น)",
        Values = {"Bottom", "Middle"},
        Default = 1,
        Multi = false
    })
    TracerOriginDropdown:OnChanged(function(val)
        ESP_Config.TracerOrigin = val
    end)

    local SliderMaxDist = Tabs.ESP:AddSlider("MaxDistance", {
        Title = "Max Distance (ระยะมองสูงสุด)",
        Default = 1500,
        Min = 100,
        Max = 3000,
        Rounding = 0,
        Callback = function(val)
            ESP_Config.MaxDistance = val
        end
    })

    local SliderTextSize = Tabs.ESP:AddSlider("TextSize", {
        Title = "Text Size (ขนาดตัวอักษร)",
        Default = 13,
        Min = 10,
        Max = 20,
        Rounding = 0,
        Callback = function(val)
            ESP_Config.TextSize = val
        end
    })

    local EnemyColorPicker = Tabs.ESP:AddColorpicker("EnemyColor", {
        Title = "Enemy Color (สีผู้เล่นศัตรู)",
        Default = Color3.fromRGB(255, 60, 60)
    })
    EnemyColorPicker:OnChanged(function(val)
        ESP_Config.EnemyColor = val or (Options.EnemyColor and Options.EnemyColor.Value) or Color3.fromRGB(255, 60, 60)
    end)

    local TeamColorPicker = Tabs.ESP:AddColorpicker("TeamColor", {
        Title = "Team Color (สีเพื่อนร่วมทีม)",
        Default = Color3.fromRGB(60, 180, 255)
    })
    TeamColorPicker:OnChanged(function(val)
        ESP_Config.TeamColor = val or (Options.TeamColor and Options.TeamColor.Value) or Color3.fromRGB(60, 180, 255)
    end)

    ---------------------------------------------------------
    -- TAB: ITEMS
    ---------------------------------------------------------
    Tabs.Items:AddParagraph({
        Title = "Dropped Item Visuals (มองไอเทมบนพื้น)",
        Content = "แสดงตำแหน่ง ชื่อ และระยะห่างของไอเทมที่ดรอปอยู่ สามารถเลือกชื่อไอเทมและหมวดหมู่ที่ต้องการมองได้"
    })

    local ToggleItemESP = Tabs.Items:AddToggle("ItemESPMaster", {
        Title = "Enable Item ESP (เปิดมองชื่อไอเทมบนพื้น)",
        Default = false
    })
    ToggleItemESP:OnChanged(function()
        Item_Config.ESPEnabled = Options.ItemESPMaster.Value
    end)

    local ToggleItemHighlight = Tabs.Items:AddToggle("ItemHighlightMaster", {
        Title = "Enable Item Highlight (เปิดไฮไลท์ไอเทมเรืองแสง 3D)",
        Description = "เปิดเรืองแสงโมเดลไอเทมบนพื้นตามสีของแต่ละหมวดหมู่ทะลุกำแพง",
        Default = true
    })
    ToggleItemHighlight:OnChanged(function()
        Item_Config.HighlightEnabled = Options.ItemHighlightMaster.Value
    end)

    local SliderItemDist = Tabs.Items:AddSlider("ItemESPMaxDist", {
        Title = "Item ESP Distance (ระยะมองไอเทมสูงสุด)",
        Default = 500,
        Min = 50,
        Max = 2000,
        Rounding = 0,
        Callback = function(val)
            Item_Config.ESPMaxDistance = val
        end
    })

    local DropdownItemFilter = Tabs.Items:AddDropdown("ItemCategoryFilter", {
        Title = "Filter Categories (เลือกหมวดหมู่ไอเทมที่จะมอง)",
        Values = {"Weapons", "Ammo", "Medical", "Shields", "Armor", "Attachments", "Other"},
        Default = {"Weapons", "Ammo", "Medical", "Shields", "Armor", "Attachments", "Other"},
        Multi = true
    })
    DropdownItemFilter:OnChanged(function(val)
        Item_Config.FilterWeapons = val["Weapons"] == true
        Item_Config.FilterAmmo = val["Ammo"] == true
        Item_Config.FilterMedical = val["Medical"] == true
        Item_Config.FilterShields = val["Shields"] == true
        Item_Config.FilterArmor = val["Armor"] == true
        Item_Config.FilterAttachments = val["Attachments"] == true
        Item_Config.FilterOther = val["Other"] == true
    end)

    local DropdownItemNames = Tabs.Items:AddDropdown("ItemNameMultiFilter", {
        Title = "Select Items to Filter (เลือกชื่อไอเทมที่ต้องการมอง)",
        Description = "เลือกได้หลายอย่างพร้อมกัน (ถ้าไม่เลือกเลย = แสดงทั้งหมดตามหมวดหมู่ด้านบน)",
        Values = ItemNamesList,
        Default = {},
        Multi = true
    })
    DropdownItemNames:OnChanged(function(val)
        Item_Config.SelectedItems = val
    end)

    Tabs.Items:AddButton({
        Title = "Clear Selected Items (ล้างชื่อไอเทมที่เลือกทั้งหมด)",
        Description = "กดเพื่อเคลียร์ตัวเลือกไอเทมทั้งหมด กลับสู่โหมดแสดงตามหมวดหมู่",
        Callback = function()
            DropdownItemNames:SetValue({})
            Item_Config.SelectedItems = {}
            Fluent:Notify({
                Title = "Item Filter Reset",
                Content = "ล้างการเลือกชื่อไอเทมเรียบร้อย (แสดงตามหมวดหมู่)",
                Duration = 3
            })
        end
    })

    Tabs.Items:AddParagraph({
        Title = "Item Category Colors (เลือกสีประจำแต่ละหมวดหมู่)",
        Content = "คลิกเพื่อเลือกสีได้ทันทีจากพาเลทสี (ทั้งไฮไลท์เรืองแสง 3D และตัวหนังสือ)"
    })

    local ColorWeaponsPicker = Tabs.Items:AddColorpicker("ColorWeapons", {
        Title = "Weapons (ปืน - สีฟ้า/น้ำเงิน)",
        Default = Color3.fromRGB(0, 200, 255)
    })
    ColorWeaponsPicker:OnChanged(function(val)
        Item_Config.ColorWeapons = val or (Options.ColorWeapons and Options.ColorWeapons.Value) or Color3.fromRGB(0, 200, 255)
    end)

    local ColorMedicalPicker = Tabs.Items:AddColorpicker("ColorMedical", {
        Title = "Medical (ยา - สีเขียว)",
        Default = Color3.fromRGB(50, 255, 100)
    })
    ColorMedicalPicker:OnChanged(function(val)
        Item_Config.ColorMedical = val or (Options.ColorMedical and Options.ColorMedical.Value) or Color3.fromRGB(50, 255, 100)
    end)

    local ColorShieldsPicker = Tabs.Items:AddColorpicker("ColorShields", {
        Title = "Shields (โล่/บังเกอร์ - สีแดง)",
        Default = Color3.fromRGB(255, 50, 50)
    })
    ColorShieldsPicker:OnChanged(function(val)
        Item_Config.ColorShields = val or (Options.ColorShields and Options.ColorShields.Value) or Color3.fromRGB(255, 50, 50)
    end)

    local ColorArmorPicker = Tabs.Items:AddColorpicker("ColorArmor", {
        Title = "Armor (เกราะ/หมวก/กระเป๋า - สีม่วง)",
        Default = Color3.fromRGB(180, 50, 255)
    })
    ColorArmorPicker:OnChanged(function(val)
        Item_Config.ColorArmor = val or (Options.ColorArmor and Options.ColorArmor.Value) or Color3.fromRGB(180, 50, 255)
    end)

    local ColorAmmoPicker = Tabs.Items:AddColorpicker("ColorAmmo", {
        Title = "Ammo (กระสุน/แม็กกาซีน - สีส้ม)",
        Default = Color3.fromRGB(255, 160, 20)
    })
    ColorAmmoPicker:OnChanged(function(val)
        Item_Config.ColorAmmo = val or (Options.ColorAmmo and Options.ColorAmmo.Value) or Color3.fromRGB(255, 160, 20)
    end)

    local ColorAttachmentsPicker = Tabs.Items:AddColorpicker("ColorAttachments", {
        Title = "Attachments (อุปกรณ์แต่ง/กล้อง - สีชมพู)",
        Default = Color3.fromRGB(255, 100, 200)
    })
    ColorAttachmentsPicker:OnChanged(function(val)
        Item_Config.ColorAttachments = val or (Options.ColorAttachments and Options.ColorAttachments.Value) or Color3.fromRGB(255, 100, 200)
    end)

    local ColorOtherPicker = Tabs.Items:AddColorpicker("ColorOther", {
        Title = "Other (ไอเทมอื่นๆ - สีขาว)",
        Default = Color3.fromRGB(230, 230, 230)
    })
    ColorOtherPicker:OnChanged(function(val)
        Item_Config.ColorOther = val or (Options.ColorOther and Options.ColorOther.Value) or Color3.fromRGB(230, 230, 230)
    end)

    Tabs.Items:AddParagraph({
        Title = "Auto Loot System (ระบบเก็บของรอบตัวอัตโนมัติ)",
        Content = "ดูดและเก็บไอเทมที่ดรอปอยู่รอบตัวเข้ากระเป๋าอัตโนมัติ สามารถตั้งระยะและความเร็วได้"
    })

    local ToggleAutoLoot = Tabs.Items:AddToggle("AutoLootMaster", {
        Title = "Enable Auto Loot (เปิดเก็บของรอบตัวอัตโนมัติ)",
        Default = false
    })
    ToggleAutoLoot:OnChanged(function(val)
        if val ~= nil then
            Item_Config.AutoLootEnabled = val
        elseif Options.AutoLootMaster then
            Item_Config.AutoLootEnabled = Options.AutoLootMaster.Value
        end
    end)

    local SliderLootRadius = Tabs.Items:AddSlider("AutoLootRadius", {
        Title = "Auto Loot Radius (ระยะเก็บของ - สตัด/เมตร)",
        Description = "กำหนดรัศมีวงรอบตัวที่จะดูดเก็บไอเทม (ค่าเริ่มต้น 25)",
        Default = 25,
        Min = 5,
        Max = 100,
        Rounding = 0,
        Callback = function(val)
            Item_Config.AutoLootRadius = val
        end
    })

    local SliderLootHold = Tabs.Items:AddSlider("AutoLootHoldTime", {
        Title = "Hold Duration (เวลากดเก็บของค้างให้เต็มหลอด - วินาที)",
        Description = "ระยะเวลากดค้างให้หลอดเต็ม 100% เพื่อให้ของเข้าตัว (ค่าเริ่มต้น 1.1s, ปรับได้สูงสุด 3.0s)",
        Default = 1.1,
        Min = 0.3,
        Max = 3.0,
        Rounding = 1,
        Callback = function(val)
            Item_Config.AutoLootHoldTime = val
        end
    })

    local SliderLootDelay = Tabs.Items:AddSlider("AutoLootDelay", {
        Title = "Auto Loot Speed / Delay (ความเร็วหน่วงระหว่างชิ้น วินาที)",
        Description = "ระยะเวลาหน่วงระหว่างการเก็บของแต่ละชิ้น (ค่าเริ่มต้น 0.15s, ปรับได้สูงสุด 3.0s)",
        Default = 0.15,
        Min = 0.05,
        Max = 3.0,
        Rounding = 2,
        Callback = function(val)
            Item_Config.AutoLootDelay = val
        end
    })

    local ToggleLootFilterOnly = Tabs.Items:AddToggle("LootFilterOnly", {
        Title = "Loot Filtered Items Only (เก็บเฉพาะไอเทมที่เปิดมองไว้)",
        Description = "เปิด = เก็บเฉพาะไอเทมที่ผ่านการเลือกในหมวดหมู่หรือชื่อด้านบน, ปิด = เก็บทุกชิ้น",
        Default = false
    })
    ToggleLootFilterOnly:OnChanged(function()
        Item_Config.AutoLootFilterOnly = Options.LootFilterOnly.Value
    end)
end

-- Save / Interface Managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/WarzByUniqueHUB")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- ══════════════════════════════════════════════════════════
    -- KEY SYSTEM & ACCOUNT SETTINGS (แท็บการตั้งค่าระบบคีย์)
    -- ══════════════════════════════════════════════════════════
    local KeySection = Tabs.Settings:AddSection("Key System & Security (ระบบคีย์)")
    Tabs.Settings:AddParagraph({
        Title = "Key System Status",
        Content = string.format("สถานะ: ผ่านการตรวจสอบแล้ว (Active)\nHWID: %s\nระบบป้องกัน: 1 Key ต่อ 1 Device", KeySystem.GetHWID())
    })
    Tabs.Settings:AddButton({
        Title = "Copy HWID (คัดลอกรหัสเครื่อง)",
        Description = "คัดลอก Hardware ID เพื่อส่งให้แอดมินปลดล็อคหรือผูกคีย์",
        Callback = function()
            KeySystem.CopyHWID()
        end
    })
    Tabs.Settings:AddButton({
        Title = "Logout / Change Key (เปลี่ยนคีย์)",
        Description = "ล้างข้อมูลคีย์ที่จำไว้ และเปิดหน้าต่างใส่คีย์ใหม่",
        Callback = function()
            KeySystem.Logout()
            Fluent:Notify({
                Title = "Key System",
                Content = "ออกจากระบบเรียบร้อย กำลังเปิดหน้าต่างใส่คีย์ใหม่...",
                Duration = 2
            })
            task.wait(0.5)
            pcall(function()
                if Window and Window.Destroy then
                    Window:Destroy()
                elseif Fluent and Fluent.GUI then
                    Fluent.GUI:Destroy()
                end
            end)
            KeySystem.OpenUI(KeySystem.Config, RunWarzScript)
        end
    })

    Window:SelectTab(1)
    SaveManager:LoadAutoloadConfig()
end

-- ========================================================
-- EXECUTE KEY SYSTEM ENTRY POINT
-- ========================================================
KeySystem.Start(KeySystem.Config, RunWarzScript)
