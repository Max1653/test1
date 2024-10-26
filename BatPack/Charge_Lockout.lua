local errorHandler  = require 'Utils.errorHandler'
local UartLog   	= require 'Utils.UartLog'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function itemObj.run()

	common.sendCmd("dut", "reg select styx", 5, "OK")

	local resp = common.sendCmd("dut", "reg read 0x24", 5, "OK")

	if string.find(resp or "", "0x0E") then
		common.sendCmd("dut", "reg write 0x24 0x08", 5, "OK")
		common.sendCmd("dut", "reg read 0x24", 5, "0x08")
	end

	libRecord.createLocalBinaryRecord()

end

function _main()

    return itemObj.executeTest()
end

function main()

    return errorHandler.cof(_main, {}, "Status_Charge_Lockout")
end