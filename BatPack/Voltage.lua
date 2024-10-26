local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'
local comFunc       = require 'Utils.CommonFunc'

function itemObj.run()
     
    local subtestname, subsubtestname = comFunc.splitRecordName(Device.subtest)
    if string.find(subsubtestname, "V1") then
        common.sendCmd("dut", "smc write BMSQ 1 0 0 0", nil, "OK")
    end
    local returnValue = common.sendCmd("dut", "device -k GasGauge --get voltage", nil, nil, "(%d+)%s*mV") 
   
    -- //Output format as below and catch the value marked in Blue
    -- 2021-04-21 02:24:34.115 <post-write>[24336]: pmuadc --sel styx --read vbat
    -- 2021-04-21 02:24:34.142 <post--read>[24336]: pmuadc --sel styx --read vbat
    -- 2021-04-21 02:24:34.142 <post--read>[24336]: PMU ADC test
    -- 2021-04-21 02:24:34.142 <post--read>[24336]: expansion styx: vbat: 3995.7264 mV

    libRecord.createParametricRecord(tonumber(returnValue))
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_Voltage")
end
