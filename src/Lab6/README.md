# Blockman Demo (Godot 4.4)

ตัวละคร Blockman (Blender + Mixamo) ใช้ Mixamo BoneMap + MeleeLib / ShooterLib จาก
[Godot4-OpenAnimationLibraries](https://github.com/catprisbrey/Godot4-OpenAnimationLibraries)

## ควบคุม
| ปุ่ม | ทำอะไร |
|---|---|
| WASD / ลูกศร | เดิน |
| Shift | วิ่ง |
| Space | กระโดด |
| J / K / L | ฟัน 1 / 2 / 3 |
| U | ShieldBash |
| R | กลิ้ง |
| H | เจ็บ |
| X / Enter | ตาย / ฟื้น |
| คลิกขวาลาก / Scroll | หมุน / ซูมกล้อง |
| ลิสต์ขวามือ | เลือกดูท่าจาก Melee / Shooter Library |

## โครงสร้าง
- `characters/` FBX ตัวละคร (import ด้วย Mixamo BoneMap)
- `animations/` MeleeLib.res, ShooterLib.res
- `scenes/demo.tscn` scene หลัก, `scenes/player.tscn` ผู้เล่น
- Web export อยู่ที่ `docs/Lab6/lab6.html`
