local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'

function itemObj.run()

    local returnValue = common.sendCmd("dut", "device -k GasGauge --get temperature", nil, nil, "(%d+)%s*C")
    libRecord.createParametricRecord(tonumber(returnValue))
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_Temperature_GG")
end