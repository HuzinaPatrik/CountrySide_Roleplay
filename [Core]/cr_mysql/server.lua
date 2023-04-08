local datas = {
    ["database"] = "mta_dev",
    ["host"] = "127.0.0.1",
    ["name"] = "root",
    ["password"] = 'password',
}

local connection

local firstConnection = true

function connectToMySQL()
    connection = dbConnect("mysql", "dbname="..datas["database"]..";host="..datas["host"]..";charset=utf8", datas["name"], datas["password"], "tag=casedb;log=1;multi_statements=1")
    if connection then
        dbExec(connection, "SET NAMES utf8")
        outputDebugString("Sikeres MYSQL kapcsolat!")
        if not firstConnection then
            restartResource(getThisResource())
            firstConnection = true
        end
    else
        outputDebugString("Sikertelen MYSQL kapcsolat!, (Result: Timer started)", 1)    
        setTimer(connectToMySQL, 10000, 1)
        firstConnection = false
    end
end
addEventHandler("onResourceStart", resourceRoot, connectToMySQL)

function getConnection(res)
    if res then
        local resName = getResourceName(res)
        if resName then
            outputDebugString("Connection requested by resource "..resName.."!")
            return connection
        end
    end
end
