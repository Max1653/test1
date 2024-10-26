local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'

function itemObj.run()

    local returnValue = common.sendCmd("dut", "smc fread BCDC", nil, "OK", "BCDC%s*=%s*(%d+)")
    libRecord.createParametricRecord(tonumber(returnValue))
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_Current_Cell_Disconnect_Check")
end