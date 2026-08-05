# MacUI — คู่มือการใช้งาน API

## เริ่มต้นใช้งาน

```lua
local Library = loadstring(game:HttpGet("URL_ของไฟล์บน_GitHub_Raw"))()

local Window = Library:CreateWindow({
    Title = "MacUI",
    Subtitle = "v1.0",
    Version = "1.0.0",
    Theme = "Dark Purple", -- ไม่ใส่ก็ได้ ค่าเริ่มต้นคือ Dark Purple
    Size = UDim2.fromOffset(620, 420), -- ไม่ใส่ก็ได้
    MinimizeKeybind = Enum.KeyCode.RightControl, -- ปุ่มลัดซ่อน/แสดงหน้าต่าง
})
```

---

## Window

| ฟังก์ชัน | คำอธิบาย |
|---|---|
| `Window:CreateTab(name, icon)` | สร้างแท็บใหม่ใน Sidebar คืนค่า `Tab` |
| `Window:SetTitle(text)` | เปลี่ยนข้อความ Title บน Title Bar |
| `Window:Destroy()` | ทำลาย UI ทั้งหมดและตัดการเชื่อมต่อทุก event |

```lua
local Tab = Window:CreateTab("Home", "🏠")
```

**ปุ่มบน Title Bar (มุมซ้ายบน แบบ macOS):**
- 🔴 แดง = ซ่อนหน้าต่าง (กดปุ่มลอย/Floating Button หรือ `MinimizeKeybind` เพื่อเรียกกลับ)
- 🟡 เหลือง = ย่อ (Minimize) เหลือแค่ Title Bar
- 🟢 เขียว = ขยายเต็มจอ/คืนขนาดเดิม (Maximize toggle)

หน้าต่างลากได้ (Drag) และจะไม่หลุดออกนอกจอ (Clamp) โดยอัตโนมัติ

---

## Tab

| ฟังก์ชัน | คำอธิบาย |
|---|---|
| `Tab:CreateSection(name)` | สร้างกล่อง Section ภายในแท็บ คืนค่า `Section` |

```lua
local Section = Tab:CreateSection("General")
```

---

## Section — Elements ทั้งหมด

ทุก Element ที่รับ `Flag` (string) จะถูกลงทะเบียนกับ Config System อัตโนมัติ เพื่อให้ `Save`/`Load` ค่าได้

### 1. Button
```lua
Section:CreateButton({
    Title = "กดฉัน",
    Callback = function()
        print("ถูกกด!")
    end,
})
```
- `api:SetTitle(text)` — เปลี่ยนข้อความปุ่ม

### 2. Toggle
```lua
local MyToggle = Section:CreateToggle({
    Title = "เปิดใช้งาน",
    Default = false,
    Flag = "enableFeature", -- ไม่บังคับ
    Callback = function(value)
        print("Toggle:", value)
    end,
})
MyToggle:SetValue(true)
print(MyToggle:GetValue())
```

### 3. Slider
```lua
local MySlider = Section:CreateSlider({
    Title = "ความเร็ว",
    Min = 0,
    Max = 100,
    Step = 1,
    Decimals = 0, -- ใส่ 1,2 ถ้าต้องการทศนิยม
    Default = 50,
    Flag = "speed",
    Callback = function(value)
        print("Slider:", value)
    end,
})
MySlider:SetValue(75)
print(MySlider:GetValue())
```
รองรับลากด้วย Mouse และ Touch พร้อมกัน อัปเดตค่าและ Callback แบบ Real-time ระหว่างลาก

### 4. Dropdown (เดี่ยว/หลายค่า)
```lua
-- เลือกได้ค่าเดียว
local Drop = Section:CreateDropdown({
    Title = "เลือกโหมด",
    Options = {"Easy", "Normal", "Hard"},
    Default = "Normal",
    Callback = function(value) print(value) end,
})

-- เลือกได้หลายค่า
local MultiDrop = Section:CreateDropdown({
    Title = "เลือกไอเทม",
    Options = {"Sword", "Shield", "Bow"},
    Multi = true,
    Default = {"Sword"},
    Callback = function(values) print(values) end, -- table {name=true,...}
})
Drop:SetOptions({"A", "B", "C"}) -- เปลี่ยนตัวเลือกใหม่
print(Drop:GetValue())
```
ปิดอัตโนมัติเมื่อคลิกนอกกล่อง

### 5. Textbox
```lua
local Box = Section:CreateTextbox({
    Title = "ชื่อผู้ใช้",
    Placeholder = "พิมพ์ที่นี่...",
    Default = "",
    Callback = function(text, enterPressed)
        print(text, enterPressed)
    end,
})
Box:SetValue("Hello")
print(Box:GetValue())
```

### 6. Label
```lua
local Lbl = Section:CreateLabel("ข้อความคงที่")
Lbl:Set("เปลี่ยนข้อความใหม่")
```

### 7. Paragraph
```lua
local Para = Section:CreateParagraph({
    Title = "หัวข้อ",
    Content = "เนื้อหารายละเอียดยาว ๆ ที่นี่",
})
Para:SetContent("เนื้อหาใหม่")
```

### 8. Divider
```lua
Section:CreateDivider()
```

### 9. Keybind
```lua
local Bind = Section:CreateKeybind({
    Title = "คีย์ลัด",
    Default = Enum.KeyCode.E,
    Flag = "toggleKey",
    Callback = function(key)
        print("กดปุ่ม:", key)
    end,
})
Bind:SetValue(Enum.KeyCode.F)
print(Bind:GetValue())
```
คลิกที่ปุ่มเพื่อเข้าโหมดรอกดคีย์ใหม่ (จะขึ้นข้อความ `...`)

### 10. Color Picker
```lua
local Picker = Section:CreateColorPicker({
    Title = "สี ESP",
    Default = Color3.fromRGB(150, 110, 255),
    Flag = "espColor",
    Callback = function(color)
        print(color)
    end,
})
Picker:SetValue(Color3.fromRGB(255, 0, 0))
print(Picker:GetValue())
```
คลิกที่กล่องสีเพื่อเปิดแผง เลือก Saturation/Value จากสี่เหลี่ยม และ Hue จากแถบด้านล่าง

---

## Notification

```lua
Library:Notify({
    Title = "สำเร็จ",
    Content = "บันทึกข้อมูลเรียบร้อย",
    Type = "Success", -- "Success" | "Info" | "Warning" | "Error" | "Loading"
    Duration = 4, -- วินาที
})
```

---

## Theme Engine

```lua
Library:SetTheme("Dark Blue")
-- ตัวเลือก: "Dark Purple", "Dark Blue", "Dark Green", "Dark Orange", "Cyber", "Neon", "Light"
```
เปลี่ยนธีมได้ตลอดเวลาแบบ Runtime ทุก Element จะ Tween สีตามธีมใหม่อัตโนมัติ

---

## Config System

```lua
-- บันทึกค่าปัจจุบันทั้งหมด (เฉพาะ Element ที่ใส่ Flag)
Library.Config:Save("profile1")

-- โหลดค่ากลับมา
Library.Config:Load("profile1")

-- ลบ
Library.Config:Delete("profile1")

-- ดูรายชื่อ config ที่เคยบันทึก
local names = Library.Config:List()

-- Export/Import เป็น JSON string เอง (เช่นจะเก็บที่อื่น)
local json = Library.Config:Export()
Library.Config:Import(json)
```
> ต้องใช้ Executor ที่รองรับ `writefile`/`readfile` (เช่น Synapse, Script-Ware) ถ้าไม่รองรับ ฟังก์ชันจะคืนค่า `false` พร้อมข้อความ error แทนที่จะทำให้เกมค้าง

---

## Floating Button (มือถือ)

เมื่อกดปุ่ม 🔴 (ปิด) หน้าต่างจะซ่อนและมีปุ่มลอย (☰) โผล่ขึ้นมาแทน
- แตะเพื่อเรียกหน้าต่างกลับมา
- ลากเพื่อย้ายตำแหน่ง ปล่อยแล้วจะ Snap ไปขอบจอที่ใกล้ที่สุด

---

## ตัวอย่างแบบเต็ม

```lua
local Library = loadstring(game:HttpGet("URL"))()

local Window = Library:CreateWindow({ Title = "MacUI Demo", Version = "1.0" })
local Home = Window:CreateTab("Home", "🏠")
local Section = Home:CreateSection("ทั่วไป")

Section:CreateButton({ Title = "ทดสอบ", Callback = function()
    Library:Notify({ Title = "กดปุ่มแล้ว", Type = "Success" })
end })

Section:CreateToggle({ Title = "เปิด Feature", Flag = "feature1", Callback = function(v) end })
Section:CreateSlider({ Title = "ความเร็ว", Min = 0, Max = 200, Default = 16, Flag = "speed" })
```

---

## ข้อจำกัดที่ควรทราบ

โค้ดผ่านการตรวจสอบความถูกต้องของ Syntax (วงเล็บ/`end`/`function` จับคู่ครบ) แบบ static เท่านั้น เนื่องจากไม่มี Roblox Engine ให้รันจริงในสภาพแวดล้อมนี้ แนะนำให้ทดสอบใน Studio หรือ Executor จริงก่อนใช้งานจริงเสมอ โดยเฉพาะ Color Picker และการปิด Dropdown เมื่อคลิกนอกกรอบ
