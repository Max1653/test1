local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'
local comFunc       = require 'Utils.CommonFunc'

function itemObj.run()

    local returnValue = common.sendCmd("dut", "device -k GasGauge --get cycle-count",nil,nil,"(%d+)%s*\n%[")    
    -- Output format as below and catch the value marked in Blue
    -- 2021-04-21 02:21:39.575 <post--read>[18842]: device -k GasGauge --get cycle-count
    -- 2021-04-21 02:21:39.575 <post--read>[18842]: 0
    
    returnValue = comFunc.trim(returnValue)
    if not returnValue or not tonumber(returnValue) then
        libRecord.createLocalBinaryRecord()
    else
        libRecord.createParametricRecord(tonumber(returnValue))
    end
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_LifeTime_CycleCount")
end