local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function itemObj.run()

    local subtestname, subsubtestname = comFunc.splitRecordName(Device.subtest)

    local impedanceTrackingBit = common.sendCmd("dut", "device -k GasGauge -g chem-cap-updates-en", nil, "Yes")
    libRecord.createLocalBinaryRecord(Device.test, subtestname, subsubtestname.."_Verify_ImpedanceTrackingBit")

    local sleepEnableBit = common.sendCmd("dut", "device -k GasGauge -e read_sleep", nil, "Sleep%s*Enabled:%s*Yes")
    libRecord.createLocalBinaryRecord(Device.test, subtestname, subsubtestname.."_Verify_SleepEnableBit")

    local sealedStatus = common.sendCmd("dut", "device -k GasGauge --get sealed", nil, "Yes")
    libRecord.createLocalBinaryRecord(Device.test, subtestname, subsubtestname.."_Verify_GaugeSealedStatus")
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_RegisterRead")
end