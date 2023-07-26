AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "flare_name"
    SWEP.Slot = 8
    SWEP.ViewModelFOV = 54
    SWEP.ViewModelFlip = false

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "flare_desc"
    }

    SWEP.Icon = "vgui/ttt/icon_flare"
end

SWEP.Base = "weapon_ttt_flaregun"
SWEP.Category = WEAPON_CATEGORY_ROLE
SWEP.Kind = WEAPON_ROLE
SWEP.CanBuy = {}

SWEP.InLoadoutFor = {ROLE_SPY}

SWEP.InLoadoutForDefault = {ROLE_SPY}

SWEP.AllowDrop = false
SWEP.LimitedStock = true

function SWEP:PrimaryAttack()
    self.BaseClass.PrimaryAttack(self)

    if SERVER and self:Clip1() <= 0 then
        self:Remove()
    end
end