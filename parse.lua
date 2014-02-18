local Parse = {}
-- This module shows how to communicate with Parse, a back-end storage service.
-- It builds upon sample code posted to Ansca Mobile's Corona forum:
-- https://developer.anscamobile.com/forum/2011/09/27/parse-backend
-- For documentation of Parse's REST API, see: https://www.parse.com/docs/rest#general
-- For debugging REST communication, http://www.hurl.it is a useful resource
-- You're on your own with this code but if I'll try to answer questions, support[at]lot49.com
-- This software is available under MIT License


--Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
--to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
--and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
--IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
--SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

value 	= require ("json")

inspect = require ("inspect")

local url = require("socket.url") -- http://w3.impa.br/~diego/software/luasocket/url.html

-- https://gist.github.com/ignisdesign/4323051
function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

function setContains(set, key)
    return set[key] ~= nil
end

--Parse data fields
local request = nil
Parse.request = request

local baseUrl = "https://api.parse.com/1/"

local class = {}
class.users = "users"
class.login = "login"
class.reset = "requestPasswordReset"
class.cases = "classes/case"

--sign up with Parse.com to obtain Application ID and REST API Key
local headers = {}
headers["X-Parse-Application-Id"]  = "[YOUR APPLICATION ID HERE]" -- your Application-Id
headers["X-Parse-REST-API-Key"]    = "[YOUR REST API KEY HERE]" -- your REST-API-Key
headers["X-Parse-Session-Token"]   = nil -- session token for altering User object

Parse.AppCallback = nil

local params = {}
params.headers = headers

--get from player input or local storage
local AccountSetup = {
	username = nil,
	password = nil,
	email = nil
}
Parse.AccountSetup = AccountSetup

local DefaultLocalAccount = {  	
	username = nil,
	password = nil,
	email = nil,
	emailVerified = nil, 	-- read-only response field
	objectId = nil,        	-- read-only response field
	createdAt = nil,       	-- read-only response field
	updatedAt = nil,       	-- read-only response field
	sessionToken = nil,     -- read-only response field
	experience = nil,
	credits = nil,
	response = nil,
	responseCode = nil,
	statusCode = nil,
	request = nil,
	errorMsg = nil
	-- define additional fields as necessary
}
Parse.DefaultLocalAccount = DefaultLocalAccount

local LocalAccount = {  	
	username = nil,
	password = nil,
	email = nil,
	emailVerified = nil, 	-- read-only response field
	objectId = nil,        	-- read-only response field
	createdAt = nil,       	-- read-only response field
	updatedAt = nil,       	-- read-only response field
	sessionToken = nil,     -- read-only response field
	experience = nil,
	credits = nil,
	response = nil,
	responseCode = nil,
	statusCode = nil,
	request = nil,
	errorMsg = nil
	-- define additional fields as necessary
}
Parse.LocalAccount = LocalAccount

local updateData = {["credits"] = 100}
Parse.updateData = updateData	

local function getStoredUsername ()
	local path = system.pathForFile( "usr.txt", system.DocumentsDirectory )

	-- io.open opens a file at path. returns nil if no file found
	local file, err = io.open( path, "r" )

	if (file) then
	   	local storedName = file:read( "*a" )
	   	return storedName
	else
		print ("Failed: ", err)
		return nil
	end

end
Parse.getStoredUsername = getStoredUsername

local function updateObj (obj, data)
    if (obj.objectId) then
		headers["Content-Type"] = "application/json"
        params.body = value.encode ( data )
		request = "updateObj"
print (baseUrl .. class.users .. "/" .. obj.objectId)

		for k,v in pairs(data) do
			print ("updateObj: ", k, ":", v)
		end

        network.request( baseUrl .. class.users .. "/" .. obj.objectId, "PUT", networkListener,  params)
	else
print ("No object to update")
    end
end
Parse.updateObj = updateObj

local function deleteObj (obj)
    if (obj.objectId) then 
		headers["Content-Type"] = "application/json"
		request = "deleteObj"
		network.request( baseUrl .. class.users .. "/" .. obj.objectId, "DELETE", networkListener,  params) 
	else
print ("No object to delete")
	end        
end
Parse.deleteObj = deleteObj

local function getObj (obj)
    if (obj.objectId) then 
		headers["Content-Type"] = "application/json"
		params.body = nil
		request = "getObj"
		network.request( baseUrl .. class.users .. "/" .. obj.objectId, "GET", networkListener,  params) 
print (baseUrl .. class.users .. "/" .. obj.objectId)
	else
print ("Not logged in.")
	end
end
Parse.getObj = getObj

local function findObj (obj)
		local storedName = getStoredUsername()
		if (not obj.username and not storedName) then
			print ("Not logged in.")
			return
	    elseif (not obj.username and storedName) then
		   obj.username = storedName
		   print ("Got stored name")
		elseif (obj.username and storedName and obj.username ~= storedName) then
			--search updated name
			obj.username = storedName
		end
		print ("obj.username: ", obj.username) 
    		--find object by username when objectId is not known
			headers["Content-Type"] = "application/json"
			params.body = nil
			local table = {}
			--find this key/value pair
			table.username = obj.username
			local string = "?where=" .. url.escape(value.encode(table))
			print ("LOOKING FOR: ", baseUrl .. class.users .. string)
			request = "findObj"
			network.request( baseUrl .. class.users .. string, "GET", networkListener,  params)
			print (baseUrl)

end
Parse.findObj = findObj

-----------------------------------------------
-- Additions and Updates
-----------------------------------------------

-- NetworkListener
local function networkListener( event )
	local response = nil
	
	LocalAccount.response = nil
	LocalAccount.errorMsg = nil

--print ("parse: ", request .. " response: ", event.response)

    if ( event.isError ) then
    	LocalAccount["request"] = request
		LocalAccount["response"] = "error"
		LocalAccount["responseCode"] = response["code"]
		LocalAccount["errorMsg"] = "Network error!"
    else
print ("Status code: ", event.status)
        response = value.decode ( event.response )

		if response["error"] then
--print (response["error"])
			if (response["code"] == 101 and request == "login") then
				LocalAccount["request"] = request
				LocalAccount["response"] = "error"
				LocalAccount["responseCode"] = response["code"]
				LocalAccount["statusCode"] = event.status
				LocalAccount["errorMsg"] = "Invalid login parameters"
			end
			if (response["code"] == 202 and request == "signup") then
				LocalAccount["request"] = request
				LocalAccount["response"] = "error"
				LocalAccount["responseCode"] = response["code"]
				LocalAccount["errorMsg"] = "Username taken"
			end
			if (response["code"] == 206 and request == "updateObj") then
				LocalAccount["request"] = request
				LocalAccount["response"] = "error"
				LocalAccount["responseCode"] = response["code"]
				LocalAccount["errorMsg"] = "Must be logged in to update object"
			end
			
        else
			--createClassObj
			if (request == "createClassObj") then
				LocalAccount.response = response
			end
			
			-- getClass or getClassFilter
			if (request == "getClass" or request == "getClassFilter") then
				if (#response["results"] > 0) then
					LocalAccount.response = response["results"]
				else
					LocalAccount.response = nil
				end
			end
			
			-- getClassQuery
			if (request == "getClassQuery") then
print("getClassQuery", inspect(response["results"]))
				if (#response["results"] > 0) then
					LocalAccount.response = response["results"]
				else
					LocalAccount.response = nil
				end
			end
						
			-- getClassObjById
			if (request == "getClassObjById") then
				LocalAccount.response = response
			end
			
        	-- SignUp
			if (request == "signup") then
				-- pass user account info to LocalAccount
			    for k,v in pairs(AccountSetup) do
					LocalAccount[k] = v	
				end

				-- pass parse response to LocalAccount
				for k,v in pairs(response) do
					LocalAccount[k] = v
				end

				-- set user email table in case password reset needs to be called
				playerEmail.email = LocalAccount["email"]
			end
			
			-- updateClassObjById
			if (request == "updateClassObjById") then
				LocalAccount.response = response
			end
			
			-- deleteClassObjById
			if (request == "deleteClassObjById") then
				LocalAccount.response = response
			end
			
			-- Login
			if (request == "login") then
				for k,v in pairs(response) do
					LocalAccount[k] = v
				end

				--set sessionToken
				headers["X-Parse-Session-Token"] = LocalAccount.sessionToken
			end

			if (request == "updateObj") then
				--get response
				for k,v in pairs(response) do
					LocalAccount[k] = v
				end
				--now update
				for k,v in pairs (updateData) do
					LocalAccount[k] = v	
				end
			end
			
			if (request == "updateObj" or request == "getObj") then
				for k,v in pairs(response) do
					LocalAccount[k] = v
				end
			end
			
			if (request == "findObj") then
					
				--parse table returned in response["results"][1]
				if (response["results"][1]) then
					for k,v in pairs(response["results"][1]) do
					LocalAccount[k] = v
					print ("k", k, "v", v)
					end
				else
--print ("Object not found")
				end
			end
			
			if (request == "deleteObj") then
			    --delete local object
				for k,v in pairs(LocalAccount) do
					LocalAccount[k] = nil	
				end
			end

			if (request == "resetPassword") then
			    for k,v in pairs(response) do
					LocalAccount[k] = v
				end
			end

       end 			-- END: if response["error"] then

    end 		-- END: if ( event.isError ) then

	--reset reference to calling function
	request = nil
	
--print ("###")
--print ("LocalAccount: ")
	for k,v in pairs(LocalAccount) do
--print (k, ":", v)
	end
--print ("###")

	Parse.AppCallback( LocalAccount )
end

-- Signup
local function signup (obj, cb)
print(inspect(obj))
	if (not obj.email and not obj.password) then
		LocalAccount["request"] = request
		LocalAccount["response"] = "error"
		LocalAccount["errorMsg"] = "Missing signup data"

		cb ( LocalAccount )
	else
		Parse.AppCallback = cb

		headers["Content-Type"]  = "application/json"
		params.body = value.encode ( obj )
		request = "signup"
print(inspect(baseUrl .. class.users))
print(inspect(params))
		network.request( baseUrl .. class.users, "POST", networkListener,  params)
	end
end
Parse.signup = signup

-- Login
local function login (obj, cb)
	if (not obj.username or not obj.password) then	
print ("No data available for login")
		LocalAccount["request"] = request
		LocalAccount["response"] = "error"
		LocalAccount["errorMsg"] = "Missing login data"

		cb ( LocalAccount )	
	else
		Parse.AppCallback = cb

		headers["Content-Type"] = "application/x-www-form-urlencoded"
		params.body = nil
		local query = "?username=" .. obj.username .. "&password=" .. obj.password
		request = "login"

		network.request( baseUrl .. class.login .. query, "GET", networkListener, params)
   	end
end
Parse.login = login

-- REQUEST PASSWORD
--[[
curl -X POST \
  -H "X-Parse-Application-Id: pGWedvCUkys8zUYymNIFARSxSFcJBOYDpgWHrQ2O" \
  -H "X-Parse-REST-API-Key: oZHIfztpCeyY5t7dNJZWWnWpf3ZqSC8rLqKEgEVV" \
  -H "Content-Type: application/json" \
  -d '{"email":"coolguy@iloveapps.com"}' \
  https://api.parse.com/1/requestPasswordReset
--]]
local function resetPassword(obj, cb)
print("resetPassword()")
	if (obj.email) then
		Parse.AppCallback = cb

		headers["Content-Type"] = "application/json"
		request = "resetPassword"
	    params.body = value.encode ( obj )

	    network.request( baseUrl .. "requestPasswordReset", "POST", networkListener,  params)
	else
		LocalAccount["request"] = request
		LocalAccount["response"] = "error"
		LocalAccount["errorMsg"] = "No email available"

		cb ( LocalAccount )
	end
end
Parse.resetPassword = resetPassword

-- CREATE
--[[
curl -X POST \
  -H "X-Parse-Application-Id: pGWedvCUkys8zUYymNIFARSxSFcJBOYDpgWHrQ2O" \
  -H "X-Parse-REST-API-Key: oZHIfztpCeyY5t7dNJZWWnWpf3ZqSC8rLqKEgEVV" \
  -H "Content-Type: application/json" \
  -d '{"description":"Exited the Crotalus tigris","phone":"240-988-3441","state":"MD","title":"The Snake Incident","city":"Germantown","zip":"20874","status":3,"fname":"Ted","streetAddress":"19859 Century Blvd","lname":"Tester 1"}' \
  https://api.parse.com/1/classes/case
--]]
local function createClassObj(obj, cb)
print("createClassObj",inspect(obj))
	Parse.AppCallback = cb

	local className = obj.className
	
	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"

	request = "createClassObj"
	
	params.body = value.encode ( obj.data )

	network.request( baseUrl .. "classes/" .. className, "POST", networkListener,  params)
end
Parse.createClassObj = createClassObj

-- READ
--[[
curl -X GET \
  -H "X-Parse-Application-Id: pGWedvCUkys8zUYymNIFARSxSFcJBOYDpgWHrQ2O" \
  -H "X-Parse-REST-API-Key: oZHIfztpCeyY5t7dNJZWWnWpf3ZqSC8rLqKEgEVV" \
  https://api.parse.com/1/classes/case
--]]
local function getClass(obj, cb)
	Parse.AppCallback = cb

	local orderBy = "createdAt"
	local className = obj.className
	
	if obj.order then
		orderBy = obj.order.sort1
	end

	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"
	request = "getClass"
	params.body = value.encode ( obj )

	network.request( baseUrl .. "classes/" .. className .. "?order=" .. orderBy, "GET", networkListener,  params)
end
Parse.getClass = getClass

-- READ FILTER
--[[
curl -X GET \
  -H "X-Parse-Application-Id: H9zUMWBtA6SGacGcSJAFfVFdSSUMa0qOVtd31CoE" \
  -H "X-Parse-REST-API-Key: kRLILQitMli6n9LabPeZXhMfE4QgYl0ithOhRZTd" \
  -G \
  --data-urlencode 'where={"caseId":"H7LFeKZ3fq"}' \
  https://api.parse.com/1/classes/comment  
--]]
local function getClassFilter(obj, cb)
	local query="?where="
	local queryData = "{"
	
	Parse.AppCallback = cb

	local className = obj.className
	
	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"
	request = "getClassFilter"
	
	-- Construct Filter parameters
	-- http://forums.coronalabs.com/topic/30487-help-with-parse-using-the-query-constraints-lua-json-networkrequest-parsecom/
	for k,v in pairs(obj.filter) do
		queryData = queryData .. '"' .. k .. '":"' .. v .. '",'
	end

	-- Remove last character - the comma
	queryData = string.sub(queryData, 1, -2) .. '}'
	
	-- Construct Sort parameters
--[[
	if setContains(obj, "order") then
print("obj", inspect(obj.order))
		queryData = queryData .. "&order=" .. obj.order.sort1
	end
--]]
	
	query = query .. urlencode(queryData)
	--query = '?where=' .. urlencode('{"caseId":"H7LFeKZ3fq"}')
	
--print("query",query)

	params.body = value.encode ( obj )

	network.request( baseUrl .. "classes/" .. className .. query, "GET", networkListener,  params)
end
Parse.getClassFilter = getClassFilter

-- READ QUERY
--[[
curl -X GET \
  -H "X-Parse-Application-Id: H9zUMWBtA6SGacGcSJAFfVFdSSUMa0qOVtd31CoE" \
  -H "X-Parse-REST-API-Key: kRLILQitMli6n9LabPeZXhMfE4QgYl0ithOhRZTd" \
  -G \
  --data-urlencode 'where={"caseId":"H7LFeKZ3fq"}' \
  https://api.parse.com/1/classes/comment  
--]]
local function getClassQuery(obj, cb)
	local query="?where="
	
	Parse.AppCallback = cb

	local className = obj.className
	local whereClause = obj.where.clause
	
	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"
	request = "getClassQuery"
	
	-- Construct Query parameters
	-- http://forums.coronalabs.com/topic/30487-help-with-parse-using-the-query-constraints-lua-json-networkrequest-parsecom/
	--query = query .. whereClause
	--query = query .. urlencode(whereClause)
print("query", inspect('?where=' .. whereClause))
	query = '?where=' .. urlencode(whereClause)

	params.body = value.encode ( obj )
	--params.body = obj
	
print("network.request", inspect(baseUrl .. "classes/" .. className .. query))
print("params", inspect(params.body))

	network.request( baseUrl .. "classes/" .. className .. query, "GET", networkListener,  params)
end
Parse.getClassQuery = getClassQuery

-- READ BY ID
--[[
curl -X GET \
  -H "X-Parse-Application-Id: pGWedvCUkys8zUYymNIFARSxSFcJBOYDpgWHrQ2O" \
  -H "X-Parse-REST-API-Key: oZHIfztpCeyY5t7dNJZWWnWpf3ZqSC8rLqKEgEVV" \
  https://api.parse.com/1/classes/case/ATcsTa3Ggz
--]]
local function getClassObjById(obj, cb)
	Parse.AppCallback = cb

	local className = obj.className
	local objId = obj.objId
	
	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"
	request = "getClassObjById"
	params.body = nil

	network.request( baseUrl .. "classes/" .. className .. "/" .. objId, "GET", networkListener,  params)
end
Parse.getClassObjById = getClassObjById

-- UPDATE BY ID
--[[
curl -X PUT \
  -H "X-Parse-Application-Id: H9zUMWBtA6SGacGcSJAFfVFdSSUMa0qOVtd31CoE" \
  -H "X-Parse-REST-API-Key: kRLILQitMli6n9LabPeZXhMfE4QgYl0ithOhRZTd" \
  -H "Content-Type: application/json" \
  -d '{"fname":"Teddy"}' \
  https://api.parse.com/1/classes/case/ATcsTa3Ggz
--]]
local function updateClassObjById(obj, cb)
	Parse.AppCallback = cb

	local className = obj.className
	local objId = obj.objId
	
	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"
	request = "updateClassObjById"
	params.body = value.encode ( obj.data )

print("updateClassObjById: objId: ", inspect(objId))
print("updateClassObjById: obj: ", inspect(obj))
print("updateClassObjById: params.body: ", inspect(params.body))

	network.request( baseUrl .. "classes/" .. className .. "/" .. objId, "PUT", networkListener,  params)
end
Parse.updateClassObjById = updateClassObjById

-- DELETE BY ID
--[[
curl -X DELETE \
  -H "X-Parse-Application-Id: H9zUMWBtA6SGacGcSJAFfVFdSSUMa0qOVtd31CoE" \
  -H "X-Parse-REST-API-Key: kRLILQitMli6n9LabPeZXhMfE4QgYl0ithOhRZTd" \
  https://api.parse.com/1/classes/case/ATcsTa3Ggz  
--]]
local function deleteClassObjById(obj, cb)
	Parse.AppCallback = cb

	local className = obj.className
	local objId = obj.objId
	
	headers["X-Parse-Session-Token"] = nil
	headers["Content-Type"] = "application/json"
	request = "deleteClassObjById"
	params.body = nil

	network.request( baseUrl .. "classes/" .. className .. "/" .. objId, "DELETE", networkListener,  params)
end
Parse.deleteClassObjById = deleteClassObjById

-- https://www.parse.com/questions/how-can-i-add-objects-to-a-relation

return Parse


