local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function itemObj.run()
    local CBATHead = "0x00000004 0x00000044 0x00001388 0x00002328 0x00003A98 0x00004E20 "
    local CBATValue = common.sendCmd("dut", "syscfg print CBAT", nil, nil, "%s*"..CBATHead.."%s*(.*)\n%[", true)

    local returnValue = common.sendCmd("dut", "smc read CBTC", nil, "OK", "00000000:%s*(%d%d)")
    if not returnValue then
        libRecord.createFailRecordWithMsg("CBTC is nil")
        return
    end

    local expectTab = {"01"}
    if not CBATValue or #CBATValue == 0 or comFunc.hasVal(expectTab, returnValue) then
        -- libRecord.createBinaryRecord(true)
        libRecord.createParametricRecord(tonumber(returnValue))
        CBATValue = string.sub(CBATHead..CBATValue, 1, 256)
        libRecord.createAttribute("CBAT", CBATValue)
    else
        local failMsg = string.format("Read CBTC is %s. But expect is '01'", returnValue)
        libRecord.createFailRecordWithMsg(failMsg)
    end
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_System_CBTC_Check")
end