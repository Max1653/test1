local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'

function itemObj.run()
     
     --[[2021-04-21 02:21:38.460 <post-write>[18842]: pmuadc --sel styx --read tbat
2021-04-21 02:21:38.486 <post--read>[18842]: pmuadc --sel styx --read tbat
2021-04-21 02:21:38.486 <post--read>[18842]: PMU ADC test
2021-04-21 02:21:38.486 <post--read>[18842]: expansion styx: tbat: 28.4896 C]]
    local returnValue = common.sendCmd("dut", "pmuadc --sel styx --read tbat", nil, "tbat:", "tbat:%s*([%-%d.]+)%s*C")
    libRecord.createParametricRecord(tonumber(returnValue))
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_Temperature_Pack")
end