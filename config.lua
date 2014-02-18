
-- http://coronalabs.com/blog/2012/12/04/the-ultimate-config-lua-file/

if string.sub(system.getInfo("model"),1,4) == "iPad" then
    -- iPad
    application = 
    {
        content =
        {
            -- graphicsCompatibility = 1,  -- Turn on V1 Compatibility Mode

            width = 360,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            fps = 60,
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
    application = 
    {
        content =
        {
            -- graphicsCompatibility = 1,  -- Turn on V1 Compatibility Mode

            width = 320,
            height = 568,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            fps = 60,
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" then
    application = 
    {
        content =
        {
            -- graphicsCompatibility = 1,  -- Turn on V1 Compatibility Mode

            width = 320,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            fps = 60,
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
elseif display.pixelHeight / display.pixelWidth > 1.72 then
    application = 
    {
        content =
        {
            -- graphicsCompatibility = 1,  -- Turn on V1 Compatibility Mode

            width = 320,
            height = 570,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            fps = 60,
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
    }
else
    application = 
    {
        content =
        {
            -- graphicsCompatibility = 1,  -- Turn on V1 Compatibility Mode

            width = 320,
            height = 512,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            fps = 60,
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
end
