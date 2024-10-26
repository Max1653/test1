local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function  Battery_Max(returnString)

    returnString = string.gsub(returnString or "", " ", "")
    local ComTable = {}
    local targetStr = string.match(returnString or "", "0000000:(%w+)")
    if(targetStr ~= nil) then
        local x, i = 0, 1
        while i <= 28 do
            local aValue = tonumber("0x"..targetStr:sub(i, i+3))
            if i==1 or i== 5 then
                aValue = aValue/10
            end
            if i==21 then
                aValue = -(65536-aValue)
            end
            table.insert(ComTable,tostring(aValue)); x = x +1
            i = i+4
        end
    end

    return ComTable[1], ComTable[2], ComTable[3], ComTable[4], ComTable[5], ComTable[6], ComTable[7]
end

function itemObj.run()

    local subtestname, subsubtestname = comFunc.splitRecordName(Device.subtest)
     
    local value_battery = common.sendCmd("dut", "device -k GasGauge -p", nil, "mV")
    -- //Catch the temperature output of ""device -k GasGauge -p""
    -- temperature: ""28C""
    
    local batteryCheckHexValue = common.sendCmd("dut", "device -k GasGauge -e read_blk 59 0", 20, "OK")
    -- "//Class 59, Block 0:
    -- 0000000: 01 29 00 F7 0F B3 0E AB 17 DF EC F4 00 00 00 00  .)..............
    -- 0000010: 29 30 28 1D 00 02 00 02 FA 15 FA 15 2C C0 2C C0  )0(.........,.,.
    -- OK
    -- /*For each value*/
    -- Max_Temp: 0x0129 => 297/10
    -- Min_Temp: 0x00F7 => 247/10
    -- Max_Pack_Voltage: 0x0FB3 => 4019
    -- Min_Pack_Voltage: 0x0EAB => 3755
    -- Max_Chg_Current: 0x17DF => 6111
    -- Max_Dhg_Current: 0xECF4 => 60660-65536 = -4876
    -- Max_Over_Chg_Cap: 0x0000 => 0"

    local Max_Temp, Min_Temp, Max_Pack_Voltage, Min_Pack_Voltage, Max_Chg_Current,Max_Dhg_Current,Max_Over_Chg_Cap = Battery_Max(batteryCheckHexValue)

    -- local limit_Max_Temp = {upperLimit = 60}
    -- local limit_Min_Temp = {lowerLimit = -20}
    -- local limit_Max_Pack_Voltage = {upperLimit = 4525}
    -- local limit_Min_Pack_Voltage = {lowerLimit = 2240}
    local suffix = ""
    if string.find(subsubtestname, "Before") then
        suffix = "_Before"
    elseif string.find(subsubtestname, "After") then
        suffix = "_After"
    end

    libRecord.createParametricRecord(tonumber(Max_Temp), Device.test, subtestname, "LifeTime_Temp_Max"..suffix)
    libRecord.createParametricRecord(tonumber(Min_Temp), Device.test, subtestname, "LifeTime_Temp_Min"..suffix)
    libRecord.createParametricRecord(tonumber(Max_Pack_Voltage), Device.test, subtestname, "LifeTime_Voltage_Max"..suffix)
    libRecord.createParametricRecord(tonumber(Min_Pack_Voltage), Device.test, subtestname, "LifeTime_Voltage_Min"..suffix)
    libRecord.createParametricRecord(tonumber(Max_Chg_Current), Device.test, subtestname, "LifeTime_ChargeCurrent_Max"..suffix)
    libRecord.createParametricRecord(tonumber(Max_Dhg_Current), Device.test, subtestname, "LifeTime_DischargeCurrent_Max"..suffix)
    libRecord.createParametricRecord(tonumber(Max_Over_Chg_Cap), Device.test, subtestname, "LifeTime_OverChargeCap_Max"..suffix)

    return value_battery
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_LifeTime")
end