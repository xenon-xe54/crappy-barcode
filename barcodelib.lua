--All functions have quiet zone with spec GS-1

local B = {}

local one_full_unit = "1"
local one_empty_unit = "0"

function CreateAuxiliary(pattern)
    local pattern_table = {
        normalGP = { 1, 1, 1 },
        centerGP = { 1, 1, 1, 1, 1 },
        special = { 1, 1, 1, 1, 1, 1 },
        quietEAN13 = { 11, 7 },
        quiet812 = { 7, 7 },
    }

    if pattern == "normal" then
        return one_full_unit .. one_empty_unit .. one_full_unit
    elseif pattern == "center" then
        return one_empty_unit .. one_full_unit .. one_empty_unit .. one_full_unit .. one_empty_unit
    elseif pattern == "special" then
        return one_empty_unit .. one_full_unit .. one_empty_unit .. one_full_unit .. one_empty_unit .. one_full_unit
    elseif pattern == "quiet13start" then
        return string.rep(one_empty_unit, pattern_table.quietEAN13[1])
    elseif pattern == "quiet" then
        return string.rep(one_empty_unit, pattern_table.quiet812[1])
    end
end

function TranslateNumber(number, subtable)
    local unit
    local first_part
    local second_part
    local third_part
    local four_part
    local encode_table = {
        zero = { 3, 2, 1, 1 },
        one = { 2, 2, 2, 1 },
        two = { 2, 1, 2, 2 },
        three = { 1, 4, 1, 1 },
        four = { 1, 1, 3, 2 },
        five = { 1, 2, 3, 1 },
        six = { 1, 1, 1, 4 },
        seven = { 1, 3, 1, 2 },
        eight = { 1, 2, 1, 3 },
        nine = { 3, 1, 1, 2 }
    }


    if number == '0' then
        unit = "zero";
    elseif number == '1' then
        unit = "one";
    elseif number == '2' then
        unit = "two";
    elseif number == '3' then
        unit = "three";
    elseif number == '4' then
        unit = "four";
    elseif number == '5' then
        unit = "five";
    elseif number == '6' then
        unit = "six";
    elseif number == '7' then
        unit = "seven";
    elseif number == '8' then
        unit = "eight";
    elseif number == '9' then
        unit = "nine";
    end
    if subtable == "tableA" then
        First_block = one_empty_unit
        Second_block = one_full_unit
        first_part = encode_table[unit][1]
        second_part = encode_table[unit][2]
        third_part = encode_table[unit][3]
        four_part = encode_table[unit][4]
    elseif subtable == "tableB" then
        First_block = one_empty_unit
        Second_block = one_full_unit
        first_part = encode_table[unit][4]
        second_part = encode_table[unit][3]
        third_part = encode_table[unit][2]
        four_part = encode_table[unit][1]
    elseif subtable == "tableC" then
        First_block = one_full_unit
        Second_block = one_empty_unit
        first_part = encode_table[unit][1]
        second_part = encode_table[unit][2]
        third_part = encode_table[unit][3]
        four_part = encode_table[unit][4]
    end
    return string.rep(First_block, first_part) ..
        string.rep(Second_block, second_part) ..
        string.rep(First_block, third_part) ..
        string.rep(Second_block, four_part)
end

-- Functon argument string with digits 0-9
-- Function return string with 0 and 1
-- 0 mean space (white)
-- 1 mean bar (black)
function B.EAN8_encode(code_string)
    local barcode = {}
    if tonumber(code_string) == nil then
        table.insert(barcode, "String must contain only digits")
        return table.concat(barcode)
    else
        table.insert(barcode, CreateAuxiliary("quiet"))
        table.insert(barcode, CreateAuxiliary("normal"))
        for i = 1, string.len(code_string) do
            if i > 4 then
                table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableC"))
            elseif i == 4 then
                table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                table.insert(barcode, CreateAuxiliary("center"))
            else
                table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
            end
        end
        table.insert(barcode, CreateAuxiliary("normal"))
        table.insert(barcode, CreateAuxiliary("quiet"))
        return table.concat(barcode)
    end
end

-- Functon argument string with digits 0-9
-- Function return string with 0 and 1
-- 0 mean space (white)
-- 1 mean bar (black)
function B.UPCA_encode(code_string)
    local barcode = {}
    if tonumber(code_string) == nil then
        table.insert(barcode, "String must contain only digits")
        return table.concat(barcode)
    else
        table.insert(barcode, CreateAuxiliary("quiet"))
        table.insert(barcode, CreateAuxiliary("normal"))
        for i = 1, string.len(code_string) do
            -- print(string.sub(code_string, i, i))
            if i > 6 then
                table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableC"))
            elseif i == 6 then
                table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                table.insert(barcode, CreateAuxiliary("center"))
            else
                table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
            end
        end
        table.insert(barcode, CreateAuxiliary("normal"))
        table.insert(barcode, CreateAuxiliary("quiet"))
        return table.concat(barcode)
    end
end

-- Functon argument string with digits 0-9
-- Function return string with 0 and 1
-- 0 mean space (white)
-- 1 mean bar (black)
function B.EAN13_encode(code_string)
    local barcode = {}
    if tonumber(code_string) == nil then
        table.insert(barcode, "String must contain only digits")
        return table.concat(barcode)
    else
        local leading_char = string.sub(code_string, 1, 1)
        if leading_char == "0" then
            return B.UPCA_encode(code_string:sub(2))
        else
            table.insert(barcode, CreateAuxiliary("quiet13start"))
            table.insert(barcode, CreateAuxiliary("normal"))


            for i = 1, string.len(code_string) do
                if i == 2 then
                    table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                elseif i == 3 then
                    if leading_char == "1" or leading_char == "2" or leading_char == "3" then
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                    else
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableB"))
                    end
                elseif i == 4 then
                    if leading_char == "4" or leading_char == "7" or leading_char == "8" then
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                    else
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableB"))
                    end
                elseif i == 5 then
                    if leading_char == "1" or leading_char == "4" or leading_char == "5" or leading_char == "9" then
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                    else
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableB"))
                    end
                elseif i == 6 then
                    if leading_char == "2" or leading_char == "5" or leading_char == "6" or leading_char == "7" then
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                    else
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableB"))
                    end
                elseif i == 7 then
                    if leading_char == "3" or leading_char == "6" or leading_char == "8" or leading_char == "9" then
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableA"))
                    else
                        table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableB"))
                    end
                    table.insert(barcode, CreateAuxiliary("center"))
                elseif i > 7 then
                    table.insert(barcode, TranslateNumber(string.sub(code_string, i, i), "tableC"))
                end
            end
            table.insert(barcode, CreateAuxiliary("normal"))
            table.insert(barcode, CreateAuxiliary("quiet"))
            return table.concat(barcode)
        end
    end
end

return B
