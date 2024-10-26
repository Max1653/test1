local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function itemObj.run()

    local subtestname, subsubtestname = comFunc.splitRecordName(Device.subtest)

    local hw_version = common.sendCmd("dut", "device -k GasGauge --get hw-version", nil, nil, "(0x%w+)")
    local fw_version = common.sendCmd("dut", "device -k GasGauge --get fw-version", nil, nil, "(0x%w+)")

    if hw_version == "0xA8" then
        libRecord.createBinaryRecord(true, Device.test, subtestname, subsubtestname.."_HW_Version")
    else
        libRecord.createFailRecordWithMsg("BATT_HW is not equal to 0xA8.", Device.test, subtestname, subsubtestname.."_HW_Version")
    end
    libRecord.createAttribute("BATT_HW_CT2", hw_version, subsubtestname.."_HW_Version")


    if fw_version == "0x610" then
        libRecord.createBinaryRecord(true, Device.test, subtestname, subsubtestname.."_FW_Version")
    else
        libRecord.createFailRecordWithMsg("BATT_FW is not equal to 0x610.", Device.test, subtestname, subsubtestname.."_FW_Version")
    end
    libRecord.createAttribute("BATT_FW_CT2", fw_version, subsubtestname.."_FW_Version")

end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Info_SysConfig_GG")
end