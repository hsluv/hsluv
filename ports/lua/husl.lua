-- Version: 1.0.0

local m = {
    { 3.240454162114103, -1.537138512797715, -0.49853140955601},
    {-0.96926603050518,   1.876010845446694,  0.041556017530349},
    { 0.055643430959114, -0.20402591351675,   1.057225188223179}
}

local m_inv = {
    {0.41245643908969,  0.3575760776439,  0.18043748326639 },
    {0.21267285140562,  0.71515215528781, 0.072174993306559},
    {0.019333895582329, 0.1191920258813,  0.95030407853636 }
}

-- hard-coded d65 illuminant
local refX = 0.95047
local refY = 1.00000
local refZ = 1.08883
local refU = (4 * refX) / (refX + (15 * refY) + (3 * refZ))
local refV = (9 * refY) / (refX + (15 * refY) + (3 * refZ))

local kappa = 24389 / 27
local epsilon = 216 / 24389

-- public api

local husl = {}

function husl.husl_to_rgb(h, s, l)
    return husl.lch_to_rgb(husl.husl_to_lch(h, s, l))
end

function husl.husl_to_hex(h, s, l)
    return husl.rgb_to_hex(husl.husl_to_rgb(h, s, l))
end

function husl.rgb_to_husl(r, g, b)
    return husl.lch_to_husl(husl.rgb_to_lch(r, g, b))
end

function husl.hex_to_husl(hex)
    return husl.rgb_to_husl(husl.hex_to_rgb(hex))
end

function husl.huslp_to_rgb(h, s, l)
    return husl.lch_to_rgb(husl.huslp_to_lch(h, s, l))
end

function husl.huslp_to_hex(h, s, l)
    return husl.rgb_to_hex(husl.huslp_to_rgb(h, s, l))
end

function husl.rgb_to_huslp(r, g, b)
    return husl.lch_to_huslp(husl.rgb_to_lch(r, g, b))
end

function husl.hex_to_huslp(hex)
    return husl.rgb_to_huslp(husl.hex_to_rgb(hex))
end

function husl.lch_to_rgb(l, c, h)
    return husl.xyz_to_rgb(husl.luv_to_xyz(husl.lch_to_luv(l, c, h)))
end

function husl.rgb_to_lch(r, g, b)
    return husl.luv_to_lch(husl.xyz_to_luv(husl.rgb_to_xyz(r, g, b)))
end

function husl.max_chroma(L, H)
    local hrad = math.rad(H)
    local sinH = math.sin(hrad)
    local cosH = math.cos(hrad)
    local sub1 = math.pow(L + 16, 3) / 1560896
    local sub2 = (sub1 > epsilon) and sub1 or (L / kappa)
    
    local result = math.huge
    
    for _, row in ipairs(m) do
        local m1, m2, m3 = unpack(row)

        local top = (12739311 * m3 + 11700000 * m2 + 11120499 * m1) * sub2
        local rbottom = 9608480 * m3 - 1921696 * m2
        local lbottom = 1441272 * m3 - 4323816 * m1

        local bottom = (rbottom * sinH + lbottom * cosH) * sub2

        local C0 = L * top / bottom
        local C1 = L * (top - 11700000) / (bottom + 1921696 * sinH)

        if C0 > 0 and C0 < result then
            result = C0
        end

        if C1 > 0 and C1 < result then
            result = C1
        end
    end

    return result
end

local function hrad_extremum(L)
    local lhs = (math.pow(L, 3) + 48 * math.pow(L, 2) + 768 * L + 4096) / 1560896
    local rhs = epsilon
    local sub = (lhs > rhs) and lhs or L / kappa

    local chroma = math.huge
    local result = nil

    for _, row in ipairs(m) do
        local m1, m2, m3 = unpack(row)
        local bottom = (3 * m3 - 9 * m1) * sub

        for limit=0,1 do
            local top = (20 * m3 - 4 * m2) * sub + 4 * limit
            local hrad = math.atan2(top, bottom)
            -- This is a math hack to deal with tan quadrants, I'm too lazy to figure
            -- out how to do this properly
            if limit == 1 then
                hrad = hrad + math.pi
            end

            local test = husl.max_chroma(L, math.deg(hrad))
            
            if test < chroma then
                chroma = test
                result = hrad
            end
        end
    end

    return result
end

function husl.max_chroma_pastel(L)
    local H = math.deg(hrad_extremum(L))
    return husl.max_chroma(L, H)
end

local function dot_product(a, b)
    local sum = 0

    for i=1,#a do
        sum = sum + a[i] * b[i]
    end

    return sum
end

function husl.f(t)
    if t > epsilon then
        return 116 * math.pow((t / refY), 1 / 3) - 16
    else
        return t / refY * kappa
    end
end

function husl.f_inv(t)
    if t > 8 then
        return refY * math.pow((t + 16) / 116, 3)
    else
        return refY * t / kappa
    end
end

function husl.from_linear(c)
    if c <= 0.0031308 then
        return 12.92 * c
    else
        return 1.055 * math.pow(c, 1 / 2.4) - 0.055
    end
end

function husl.to_linear(c)
    local a = 0.055

    if c > 0.04045 then
        return math.pow((c + a) / (1 + a), 2.4)
    else
        return c / 12.92
    end
end

local function round(number, digits)
    local f = math.pow(10, digits or 0)

    return math.floor(number * f + 0.5) / f
end

function husl.rgb_prepare(r, g, b)
    local prepared = {}

    for i, component in ipairs{r, g, b} do
        component = round(component, 3)

        assert(component >= -0.0001 and component <= 1.0001, "illegal rgb value " .. component)

        component = math.min(1, math.max(component, 0))
    
        prepared[i] = round(component * 255)
    end

    return unpack(prepared)
end

function husl.hex_to_rgb(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255
    
    return r, g, b
end

function husl.rgb_to_hex(r, g, b)
    return string.format("#%02x%02x%02x", husl.rgb_prepare(r, g, b))
end

function husl.xyz_to_rgb(x, y, z)
    local rgb = {}

    for i, row in ipairs(m) do
        rgb[i] = husl.from_linear(dot_product(row, {x, y, z}))
    end

    return unpack(rgb)
end

function husl.rgb_to_xyz(r, g, b)
    local rgb = {
        husl.to_linear(r),
        husl.to_linear(g),
        husl.to_linear(b),
    }

    local xyz = {}

    for i, row in ipairs(m_inv) do
        xyz[i] = dot_product(row, rgb)
    end

    return unpack(xyz)
end

function husl.xyz_to_luv(X, Y, Z)
    if X == 0 and Y == 0 and Z == 0 then
        return 0, 0, 0
    end

    local varU = (4 * X) / (X + (15 * Y) + (3 * Z))
    local varV = (9 * Y) / (X + (15 * Y) + (3 * Z))
    local L = husl.f(Y)

    -- Black will create a divide-by-zero error
    if L == 0.0 then
        return 0, 0, 0
    end

    local U = 13 * L * (varU - refU)
    local V = 13 * L * (varV - refV)

    return L, U, V
end

function husl.luv_to_xyz(L, U, V)
    if L == 0 then
        return 0, 0, 0
    end

    local varY = husl.f_inv(L)
    local varU = U / (13 * L) + refU
    local varV = V / (13 * L) + refV
    local Y = varY * refY
    local X = -(9 * Y * varU) / ((varU - 4) * varV - varU * varV)
    local Z = (9 * Y - (15 * varV * Y) - (varV * X)) / (3 * varV)

    return X, Y, Z
end

function husl.luv_to_lch(L, U, V)
    local C = (math.pow(math.pow(U, 2) + math.pow(V, 2), 0.5))
    local hrad = (math.atan2(V, U))
    local H = math.deg(hrad)
    
    if H < 0 then
        H = 360 + H
    end

    return L, C, H
end

function husl.lch_to_luv(L, C, H)
    local Hrad = math.rad(H)
    local U = math.cos(Hrad) * C
    local V = math.sin(Hrad) * C

    return L, U, V
end

function husl.husl_to_lch(H, S, L)
    if L > 99.9999999 then
        return 100, 0, H
    elseif L < 0.00000001 then
        return 0, 0, H
    end

    local mx = husl.max_chroma(L, H)
    local C = mx / 100 * S

    return L, C, H
end

function husl.lch_to_husl(L, C, H)
    if L > 99.9999999 then
        return H, 0, 100
    elseif L < 0.00000001 then
        return H, 0, 0
    end

    local mx = husl.max_chroma(L, H)
    local S = C / mx * 100

    return H, S, L
end

function husl.huslp_to_lch(H, S, L)
    if L > 99.9999999 then
        return 100, 0, H
    elseif L < 0.00000001 then
        return 0, 0, H
    end

    local mx = husl.max_chroma_pastel(L)
    local C = mx / 100 * S

    return L, C, H
end

function husl.lch_to_huslp(L, C, H)
    if L > 99.9999999 then
        return H, 0, 100
    elseif L < 0.00000001 then
        return H, 0, 0
    end

    local mx = husl.max_chroma_pastel(L)
    local S = C / mx * 100

    return H, S, L
end

return husl
