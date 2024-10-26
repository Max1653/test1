local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'
local comFunc       = require 'Utils.CommonFunc'

function itemObj.run()

    --[["Output format as below and catch the value marked in Blue
2021-04-21 02:21:39.543 <post--read>[18842]: device -k GasGauge --get nominal-capacity
2021-04-21 02:21:39.543 <post--read>[18842]: 11110mAh"]]
    local returnValue = common.sendCmd("dut", "device -k GasGauge --get nominal-capacity", nil, "mAh", "(%w+)mAh")

    local product = comFunc.getProduct()
    local limit = nil
    if product == "J817" then
        limit = {upperLimit = 8819, lowerLimit = 8017, units = "mAh"}
    elseif product == "J820" then
        limit = {upperLimit = 11046, lowerLimit = 10042, units = "mAh"}
    end
    libRecord.createParametricRecord(tonumber(returnValue), nil, nil, nil, limit)
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_NCC")
end