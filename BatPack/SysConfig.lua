local errorHandler  = require 'Utils.errorHandler'
local itemObj       = require 'Utils.itemOverrideFT'
local libRecord 	= require 'Utils.Record'
local comFunc   	= require 'Utils.CommonFunc'
local common		= require 'Utils.Communications'

function cellVendor(chemid)
    local product = comFunc.getProduct()
    if product == "J817" then
        if chemid == "0x7240" then
            return "ATL"
        elseif chemid == "0x7328" then
            return "FDB"
        end
    elseif product == "J820" then
        if chemid == "0x7260" then
            return "ATL"
        elseif chemid == "0x7327" then
            return "FDB"
        end
    end
end

function checkValue(input)
    local product = comFunc.getProduct()
    local expect = ""
    if product == "J817" then
        expect = "0x7240;0x7328" -- ChemID ATL:0x7240 FDB:0x7328
    elseif product == "J820" then
        expect = "0x7260;0x7327"
    end

    local checkTab = {}
    if string.find(expect,";") then
        checkTab = comFunc.splitString(expect,";")
    else
        table.insert(checkTab,expect)
    end

    return comFunc.hasVal(checkTab,input)
end

function Static_DF_CheckSum(chemID, DFCks)
    local bResult = false

    local product = comFunc.getProduct()
    if product == "J817" then
        if chemID == "0x7240" and DFCks == "0x0156" or
            chemID == "0x7328" and DFCks == "0x7B52" then
            bResult = true
        end
    elseif product == "J820" then
        if chemID == "0x7260" and DFCks == "0x7E4E" or
            chemID == "0x7327" and DFCks == "0x7C1A" then
            bResult = true
        end
    end

    return bResult
end

function Static_Chem_ID_CheckSum(chemID, chemIDCks)
    if not chemID or not chemIDCks then
        return false
    end
    local bResult = false

    local product = comFunc.getProduct()
    if product == "J817" then
        if chemID == "0x7240" and chemIDCks == "0x7508" or
            chemID == "0x7328" and chemIDCks == "0x6E8E" then
            bResult = true
        end
    elseif product == "J820" then
        if chemID == "0x7260" and chemIDCks == "0x7130" or
            chemID == "0x7327" and chemIDCks == "0x6E99" then
            bResult = true
        end
    end

    return bResult
end

function itemObj.run()

    local subtestname, subsubtestname = comFunc.splitRecordName(Device.subtest)

    local chem_id = common.sendCmd("dut", "device -k GasGauge --get chem-id", nil, nil, "(0x%w+)")
    libRecord.createBinaryRecord(checkValue(chem_id), Device.test, subtestname, subsubtestname.."_ChemID")
    libRecord.createAttribute("BATT_ChemID_CT2", chem_id, subsubtestname.."_ChemID")

    local response = common.sendCmd("dut", "device -k GasGauge -e test_checksum",nil, "PASS")

    local StaticDataFlash_CheckSum = string.match(response, "Static%s*Calculated%s*Checksum%s*=%s*(0x%w+)")
    local resultDataFlash = Static_DF_CheckSum(chem_id,StaticDataFlash_CheckSum)
    libRecord.createAttribute("BATT_SDFCS_CT2", StaticDataFlash_CheckSum, subsubtestname.."_StaticDataFlash_CheckSum")
    libRecord.createBinaryRecord(resultDataFlash, Device.test, subtestname, subsubtestname.."_StaticDataFlash_CheckSum")

    local StaticChemID_CheckSum = string.match(response, "Chem%s*Calculated%s*Checksum%s*=%s*(0x%w+)")
    local resultChemID = Static_Chem_ID_CheckSum(chem_id,StaticChemID_CheckSum)
    libRecord.createAttribute("BATT_SCCS_CT2", StaticChemID_CheckSum, subsubtestname.."_StaticChemID_CheckSum")
    libRecord.createBinaryRecord(resultChemID, Device.test, subtestname, subsubtestname.."_StaticChemID_CheckSum")

    return cellVendor(chem_id)
end

function _main()
    return itemObj.executeTest()
end

function main()

    return errorHandler.cof(_main, {}, "Info_SysConfig")
end