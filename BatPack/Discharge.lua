local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function itemObj.run()

    local subtestname, subsubtestname = comFunc.splitRecordName(Device.subtest)

-- 1. After setting the drain current, read keys B0AV, B0AC, VP0B and average the data 20 readings
-- 2. Discharge_Voltage_Delta=B0AV - VP0B
    local B0AV = 0
    local VP0B = 0
    local B0AC = 0
    local Voltage_Delta = 0
    local Resistance = 0

    common.sendCmd("dut", "bl -h")
    common.sendCmd("dut", "wait 2000")

    for i=1,20 do
        local returnValue1 = common.sendCmd("dut", "device -k GasGauge --get voltage")
        B0AV = B0AV + (tonumber(string.match(returnValue1 or "","([%d%-.]+)%s*mV")) or 0)
        local returnValue2 = common.sendCmd("dut", "pmu --readadc vbat")
        VP0B = VP0B + (tonumber(string.match(returnValue2 or "","vbat:%s*([%d%-.]+)%s*mV")) or 0)
        local returnValue3 = common.sendCmd("dut", "device -k GasGauge --get current")
        B0AC = B0AC + (tonumber(string.match(returnValue3 or "","([%d%-.]+)%s*mA")) or 0)
        common.sendCmd("dut", "wait 500")
    end

    common.sendCmd("dut", "bl -t 80", nil, "OK")

    B0AV = B0AV/20
    VP0B = VP0B/20
    B0AC = B0AC/20
    Voltage_Delta = B0AV - VP0B
    if B0AC ~= 0 then
        Resistance = Voltage_Delta/math.abs(B0AC)
    end

    libRecord.createParametricRecord(B0AV, Device.test, subtestname, subsubtestname.."_B0AV")
    libRecord.createParametricRecord(VP0B, Device.test, subtestname, subsubtestname.."_VP0B")
    libRecord.createParametricRecord(B0AC, Device.test, subtestname, subsubtestname.."_B0AC")
    libRecord.createParametricRecord(Voltage_Delta, Device.test, subtestname, subsubtestname.."_Voltage_Delta")
    libRecord.createParametricRecord(Resistance, Device.test, subtestname, subsubtestname.."_Resistance")
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_Discharge")
end