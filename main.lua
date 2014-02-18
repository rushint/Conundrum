-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------
-- Required Libraries
-- ---------------------------------------------------------------------------------------
local widget 		= require( "widget" )
local Parse 		= require( "parse")

local inspect 		= require( "inspect" )
-- ---------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------
-- Page variables
-- ---------------------------------------------------------------------------------------
local monthAbbrv = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"}

local centerX = display.contentWidth * 0.5
local centerY = display.contentHeight * 0.5

local myTeasers = nil
local lastPage = nil

--local prev
-- ---------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------
-- Event Listeners
-- ---------------------------------------------------------------------------------------
function paperTapListener( self, event )
	transition.to(self, {time=100, rotation=30, onComplete=
		function()
			transition.to(self, {time=100, y=self.y+150, alpha=0, onComplete=
				function()

				end
			})
		end
	})

	-- Do not return true. It mat disable the TableView scrolling.
	-- return true
end

function tblvLevelsRowRender( event )
	local row = event.row

	local rowDate = row.params.myDate
	local rowText = row.params.myText
	local rowSolution = row.params.mySolution
	local rowDateAngle = row.params.dateAngle

	grpLevel = display.newGroup()

	-- Post It
	row.postIt = display.newImage( "images/postit.png" )
	row.postIt.anchorX, row.postIt.anchorY = 0.5, 0
	row.postIt.x = centerX
	row.postIt.y = 15
	row.postIt.myName = "postit"

	grpLevel:insert(row.postIt)

	row:insert( grpLevel )

	-- The row's date
	row.myDate = display.newText( rowDate, 0, 0, native.systemFont, 20 )
	row.myDate.anchorX = 0
	row.myDate.anchorY = 0.5
	row.myDate.x = row.postIt.x + 10
	row.myDate.y = row.postIt.y + 90
	row.myDate.rotation = rowDateAngle
	row.myDate:setFillColor( 0.3 )

	grpLevel:insert(row.myDate)

	row:insert( grpLevel )

	-- The row's Text
	local options = {
	    text = rowText,
	    x = row.postIt.x,
	    y = row.postIt.y + (row.postIt.height * 0.5) + 45,
	    width = 280,
	    height = 224,
	    font = native.systemFontBold,   
	    fontSize = 14,
	    align = "left"  --new alignment parameter
	}
	row.myText = display.newText( options )
	row.myText:setFillColor( 0 )

	grpLevel:insert(row.myText)

	row:insert( grpLevel )

	-- The row's Solution
	local options = {
	    text = rowSolution,
	    x = row.postIt.x,
	    y = row.postIt.y + row.postIt.height + 70,
	    width = 225,
	    height = 105,
	    font = native.systemFontBold,   
	    fontSize = 14,
	    align = "center"
	}
	row.mySolution = display.newText( options )
	row.mySolution:setFillColor( 1 )

	grpLevel:insert(row.mySolution)

	row:insert( grpLevel )

	-- Paper
	row.paper = display.newImage( "images/pieceofpaper.png" )
	row.paper.anchorX, row.paper.anchorY = 0.2, 0.2
	row.paper.x = row.postIt.x - (row.postIt.width * 0.5) + 60
	row.paper.y = row.postIt.y + row.postIt.height + 20
	row.paper.tap = paperTapListener
	row.paper:addEventListener("tap", row.paper)

	row.paper.myName = "paper"

	grpLevel:insert(row.paper)

	row:insert( grpLevel )

end	

function onScrollComplete()
	transition.to(imgPleaseWait, {time=800, alpha=0})
    transition.to(tblvLevels, {time=800, delay=400, alpha=1.0})
end

function getClassCallback( obj )
	myTeasers = obj.response

	fillTableView()

	lastPage = (#myTeasers * display.contentHeight) - display.contentHeight

	-- Scroll the table view to the last page containing the most recent brain teaser
	tblvLevels:scrollToY( { y=-lastPage, onComplete=onScrollComplete } )
end
-- ---------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------
-- Page Methods
-- ---------------------------------------------------------------------------------------
function fillTableView()
	local myDateStr = ""
	local myMonthDay = ""

	for i = 1, #myTeasers do
		myDateStr = string.sub(myTeasers[i].myDate.iso, 6)
		myMonth = string.sub( myDateStr, 1, 2 )
		myMonthStr = monthAbbrv[math.abs(myMonth)]
		myDateStr = string.sub(myDateStr, 4)
		myDay = string.sub( myDateStr, 1, 2 )
		myMonthDay = myMonthStr .. " " .. myDay

		tblvLevels:insertRow
		{
			rowHeight = display.contentHeight,
			rowColor = { default = { 1, 1, 1, 0.0 }, },
			lineColor = { 0, 0.2, 1, 0.7 },
			id = "row" .. i,
			params = {myText = tostring(myTeasers[i].myText), myDate=myMonthDay, mySolution=myTeasers[i].mySolution, dateAngle=myTeasers[i].dateAngle},
		}
	end
end

function populateView()
	-- Background
	imgBg = display.newImage( "images/bg.png" )
	imgBg.anchorX, imgBg.anchorY = 0.5, 0.5
	imgBg.x = centerX
	imgBg.y = centerY
	imgBg.alpha = 0.3

	-- Create Table View
	tblvLevels = widget.newTableView{
		left = 0,
		top = 0,
        width = display.contentWidth,
        height = display.contentHeight,
        hideBackground = true,
		isLocked = false,
		friction = 0.2,
		maxVelocity = 5,
		maskFile = "images/generic_mask.png",
		onRowRender = tblvLevelsRowRender, 
		onRowTouch = tblvLevelsTouchHandler
    }
    tblvLevels.anchorX, tblvLevels.anchorY = 0, 0
    tblvLevels.x = 0
    tblvLevels.y = 0
    tblvLevels.alpha = 0.0

    -- Please Wait
	imgPleaseWait = display.newImage( "images/pleasewait.png" )
	imgPleaseWait.anchorX, imgPleaseWait.anchorY = 0.5, 0.5
	imgPleaseWait.x = centerX
	imgPleaseWait.y = centerY
end

function init()
	populateView()

	local obj = {}
	obj.order = {}
	obj.className = "teaser"
	obj.order.sort1 = "myDate"
	Parse.getClass(obj, getClassCallback)
end
-- ---------------------------------------------------------------------------------------

init()








