local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local common		= require 'Utils.Communications'
local comFunc       = require 'Utils.CommonFunc'

function itemObj.run()

    local returnValue = common.sendCmd("dut", "device -k GasGauge -g charge-percentage", nil, nil, "(%d+)%%")
    -- //Output format as below and catch the value marked in Blue
    -- 2021-04-21 02:24:34.078 <post--read>[24336]: [001A543C:2400291E] :-) 
    -- 2021-04-21 02:24:34.087 <post-write>[24336]: device -k GasGauge -g charge-percentage
    -- 2021-04-21 02:24:34.108 <post--read>[24336]: device -k GasGauge -g charge-percentage
    -- 2021-04-21 02:24:34.108 <post--read>[24336]: 54%
    -- 2021-04-21 02:24:34.108 <post--read>[24336]: [001A543C:2400291E] :-) 

    libRecord.createParametricRecord(tonumber(returnValue))

    if returnValue and tonumber(returnValue) <= 30 then
        local InteractiveView = Device.getPlugin("interactiveUIToolbox")
        InteractiveView.displayTextConfig(Device.systemIndex, "机台电量低于30%，请尽快充电！", "OK")

        -- loopsCount = InteractiveView.getLoops()
        -- if loopsCount > 1 then
        --     comFunc.sleep(1)
        --     os.execute(os.getenv("HOME") .. "/Desktop/stopAtlas2.command")
        -- end
    end
end

function _main()

    return itemObj.executeTest()
end

function main()

    errorHandler.cof(_main, {}, "Status_SOC")
end