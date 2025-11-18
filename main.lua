local barcode = require('barcodelib') -- Only this string you need to use library
-- This utility-"library" independent. It's only LUA code
-- Below this line example you can use it or can not use it
--
local io = require('io')
-- Be careful line below not contain 'n' in read() because barcode may have leading '0'
local string_digits = tostring(io.read())

function PrintBarcode(string)
    local one_full_unit = "█"
    local one_empty_unit = "░"
    for i = 1, 5 do
        for j = 1, string.len(string) do
            if string.sub(string, j, j) == "1" then
                io.write(one_full_unit)
            elseif string.sub(string, j, j) == "0" then
                io.write(one_empty_unit)
            else io.write(string.sub(string, j+1, j)) return --This condition for error message
            end
        end
        io.write("\n")
    end
end

if string.len(string_digits) == 8 then
    PrintBarcode(barcode.EAN8_encode(string_digits))
    print(barcode.EAN8_encode(string_digits))
elseif string.len(string_digits) == 12 then
    PrintBarcode(barcode.UPCA_encode(string_digits))
    print(barcode.UPCA_encode(string_digits))
elseif string.len(string_digits) == 13 then
    PrintBarcode(barcode.EAN13_encode(string_digits))
    print(barcode.EAN13_encode(string_digits))
else
    print("Other case's")
end
