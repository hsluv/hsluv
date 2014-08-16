local husl = require "husl"
local json = require "cjson"

do
    local function assert_tuples_close(a, b)
        local string_a = string.format("(%f,%f,%f)", a[1], a[2], a[3])
        local string_b = string.format("(%f,%f,%f)", b[1], b[2], b[3])

        for i=1,#a do
            assert(math.abs(a[i] - b[i]) < 0.00000001, "Mismatch: " .. string_a .. " " .. string_b)
        end
    end

    local function assert_equal(a, b)
        assert(a == b, "Mismatch: " .. a .. " " .. b)
    end

    local file = io.open("snapshot-rev2.json", "r")
    local content = file:read("*all")
    file:close()

    local snapshot = json.decode(content)

    for hex_color, colors in pairs(snapshot) do
        -- test forward functions
        local test_rgb = {husl.hex_to_rgb(hex_color)}
        assert_tuples_close(test_rgb, colors.rgb)
        local test_xyz = {husl.rgb_to_xyz(unpack(test_rgb))}
        assert_tuples_close(test_xyz, colors.xyz)
        local test_luv = {husl.xyz_to_luv(unpack(test_xyz))}
        assert_tuples_close(test_luv, colors.luv)
        local test_lch = {husl.luv_to_lch(unpack(test_luv))}
        assert_tuples_close(test_lch, colors.lch)
        local test_husl = {husl.lch_to_husl(unpack(test_lch))}
        assert_tuples_close(test_husl, colors.husl)
        local test_huslp = {husl.lch_to_huslp(unpack(test_lch))}
        assert_tuples_close(test_huslp, colors.huslp)

        -- test backward functions
        local test_lch = {husl.husl_to_lch(unpack(colors.husl))}
        assert_tuples_close(test_lch, colors.lch)
        local test_lch = {husl.huslp_to_lch(unpack(colors.huslp))}
        assert_tuples_close(test_lch, colors.lch)
        local test_luv = {husl.lch_to_luv(unpack(test_lch))}
        assert_tuples_close(test_luv, colors.luv)
        local test_xyz = {husl.luv_to_xyz(unpack(test_luv))}
        assert_tuples_close(test_xyz, colors.xyz)
        local test_rgb = {husl.xyz_to_rgb(unpack(test_xyz))}
        assert_tuples_close(test_rgb, colors.rgb)
        assert_equal(husl.rgb_to_hex(unpack(test_rgb)), hex_color)

        -- full test
        assert_equal(husl.husl_to_hex(unpack(colors.husl)), hex_color)
        assert_tuples_close({husl.hex_to_husl(hex_color)}, colors.husl)
        assert_equal(husl.huslp_to_hex(unpack(colors.huslp)), hex_color)
        assert_tuples_close({husl.hex_to_huslp(hex_color)}, colors.huslp)
    end
end
