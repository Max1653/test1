local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'
local helpers 		= require 'Schooner/SchoonerHelpers'
local comFunc   	= require 'Utils.CommonFunc'

function itemObj.run(cellVendor)
    local returnValue = common.sendCmd("dut", "device -k GasGauge --get chem-capacity", nil, "mAh", "(%w+)mAh")
	if not helpers.isNonEmptyString(cellVendor) then
		return libRecord.createFailRecordWithMsg("Invalid cellVendor.")
	end

    local limit = {}
    local product = comFunc.getProduct()
    if product == "J817" then
        if cellVendor == "ATL" then
            limit = {upperLimit = 9782, lowerLimit = 8152, units = "mAh"}
        elseif cellVendor == "FDB" then
            limit = {upperLimit = 9804, lowerLimit = 8170, units = "mAh"}
        end
    elseif product == "J820" then
        if cellVendor == "ATL" then
            limit = {upperLimit = 12252, lowerLimit = 10210, units = "mAh"}
        elseif cellVendor == "FDB" then
            limit = {upperLimit = 12281, lowerLimit = 10234, units = "mAh"}
        end
    end
    libRecord.createParametricRecord(tonumber(returnValue), nil, nil, nil, limit)
end

function _main(cellVendor)

    return itemObj.executeTest(cellVendor)
end

function main(cellVendor)

    errorHandler.cof(_main, {cellVendor}, "Status_Qmax")
end