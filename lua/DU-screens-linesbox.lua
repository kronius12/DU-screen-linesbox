-- # DU-screen-linesbox
-- Source and usage: https://github.com/kronius12/DU-screen-linesbox
-- License: GNU Public License 3.0
-- Version 1.0.0
--
-- This creates a column of text and images on-screen inside a box.
-- Each line has text of a single style, an image, or both.
-- Successive calls to writeTextArea() will create text
-- boxes at specified positions and sizes.

-- ***** 1) EDIT CONTENT HERE *****
-- See github README.md for parameters.

local content= {
{message="DU-screen-linesbox", style="heading" },
{message=".lua", style="heading" },
{message="Styled text over image", style="blue", lineHeight = 4,
     imgPath="resources_generated/iconsLib/elementslib/coreunitstatic256.png"},
{message="Source and usage: ", style="green"},
{message="https://github.com/kronius12", style="orange"},
{message="/DU-screen-linesbox", style="orange"},
}

-- ***** 2) STYLE DEFS *****

-- default parameters
defaultFontSize = 60          -- reduce this to fit more text
defaultLineHeight = 1.0       -- a standard line is 1 line high, or change to defaultFontSize if you'd rather use pixels
defaultTextAlign = "center"   -- text and images
backgroundColor = {16,16,80}  -- screen background

local function getStyles()
    -- you can edit, see documentation for available parameters

    local styles={}

    -- default must be fully specified
    styles.default={ 
        fontName="RobotoCondensed", 
        fontSize=defaultFontSize, 
        lineHeight=defaultLineHeight,
        align=defaultTextAlign,
        colorRgba={255,255,255,1.0},
        }
    styles.default.font = loadFont(styles.default.fontName, styles.default.fontSize)

    -- other styles as wanted
    styles.heading={
        fontName="Play-Bold", 
        fontSize=defaultFontSize * 1.5, 
        lineHeight=defaultLineHeight * 1.4, 
        colorRgba={196,255,255,1.0}}
    styles.heading.font = loadFont(styles.heading.fontName, styles.heading.fontSize)

    -- default font is used where parameters not given
    styles.green={colorRgba={0,255,255,1.0}}
    styles.red={colorRgba={220,0,0,1.0}}
    styles.blue={colorRgba={0,0,255,1.0}}
    styles.orange={colorRgba={255,255,0,1.0}}

    return styles
end

-- ***** 3) CALL IT *****
local function main()
    local rx, ry = getResolution() -- Gets the resolution of the screen
    local imgLayer = createLayer()   -- Creates a layer on top of boxLayer
    local textLayer = createLayer()  -- Creates a layer on top of boxLayer and imgLayer
    local styles = getStyles()       -- Table of styles for this text
    setBackgroundColor(normaliseRgb(backgroundColor))

    -- *** EDIT THIS ***
    
    -- write content
    writeTextArea(textLayer, imgLayer, content, styles)

    -- *** END OF EDIT THIS ***
end

-- ***** WORKINGS *****
defaultStyleName = "default" -- option to set a different default

-- function defs
function normaliseRgb(rgb)   return rgb[1]/255, rgb[2]/255, rgb[3]/255 end
function normaliseRgba(rgba) return rgba[1]/255,rgba[2]/255,rgba[3]/255, rgba[4] end


function getLineCount(content, styles)
    -- sums .lineHeight
    local totalLines = defaultLineHeight -- half a line clear top and bottom
    for i = 1, #content do
        local style = content[i].style or defaultStyleName
        local lineHeight = (content[i].lineHeight or (styles[style].lineHeight or defaultLineHeight))
        totalLines = totalLines + lineHeight
    end
    return totalLines
end

local function getBoxProperties(totalLines, xPos, yPos, width, height)
    -- determines box dimensions and centreline
    local boxProperties = {}
    local rx, ry = getResolution() -- Gets the resolution of the screen
    boxProperties.boxXpos = (xPos or 0)
    boxProperties.boxYpos = (yPos or 0)
    boxProperties.boxW = (width or (rx - (xPos or 0)))
    boxProperties.boxH = (height or (ry - (yPos or 0)))
    return boxProperties

end

local function getTextAreaProperties(totalLines, paddingX, paddingY, box)
    -- determines box dimensions and centreline
    local textArea = {}
    local rx, ry = getResolution() -- Gets the resolution of the screen
    textArea.paddingX = paddingX or 0
    textArea.paddingY = (paddingY or paddingX) or 0
    textArea.xPos = box.boxXpos + textArea.paddingX     -- top left of text area
    textArea.yPos = box.boxYpos + textArea.paddingY     -- top left of text area
    textArea.width = box.boxW - textArea.paddingX * 2   -- text area size
    textArea.height = box.boxH - textArea.paddingY * 2  -- text area size
    textArea.leftPos = textArea.xPos                       -- left inner edge
    textArea.centerPos = textArea.xPos + (textArea.width/2.0) -- centreline
    textArea.rightPos = textArea.xPos + textArea.width  -- right inner edge
    textArea.verticalPitch = (textArea.height/totalLines)
    return textArea
end

local function getImageProperties(content, line, lineHeight, textArea, align)

    local img = {}
    local aspect = 1.0 -- API doesn't inspect img so work it out
    local imgAspectWidth = (content.width or 0)
    local imgAspectHeight = (content.height or 0)
    if imgAspectWidth > 0 and imgAspectHeight > 0 then
        aspect = content.imgAspectWidth / content[i].imgAspectHeight
    end
    img.aspect = aspect

    -- image size if scaled to line height
    local imgLineHeight = textArea.verticalPitch * lineHeight
    local imgLineWidth = imgLineHeight * aspect
    if imgLineWidth > textArea.width then
        imgLineWidth = textArea.width
        imgLineHeight = imgLineWidth / aspect
    end

    -- image dimensions
    if content.imgPosX and content.imgPosY then
        -- absolute position, so use absolute size if given
        img.width = content.width or imgLineWidth
        img.height = content.height or imgLineHeight
    else
        -- scale to line height 
        img.width = imgLineWidth
        img.height = imgLineHeight
    end

    -- image top left position
    local imgX=0
    local imgAlign = (align or defaultTextAlign)
    if imgAlign=="left" then
        imgX = textArea.leftPos -- left justified
    elseif imgAlign=="right" then
        imgX = textArea.rightPos - img.width -- right justified
    else
        imgX = textArea.centerPos - img.width/2 -- centred
    end
    local imgY = textArea.yPos + line*textArea.verticalPitch -- immediately below previous line
    img.posX = content.imgPosX or imgX
    img.posY = content.imgPosY or imgY

    return img
end

local function drawBox(boxLayer, box)
    -- This draws the box the image and text sit on top of.
    -- Returns boolean if box was drawn, so text color can be adjusted if needed.
    local boxDrawn = false
    local boxBackgroundRgba = box.boxBackgroundColor
    if #boxBackgroundRgba == 3 then table.insert(boxBackgroundRgba, 1.0) end
    if boxLayer and #boxBackgroundRgba == 4 then 
        setNextFillColor(boxLayer, normaliseRgba(boxBackgroundRgba) )
        addBox(boxLayer, box.boxXpos, box.boxYpos, box.boxW, box.boxH)
        boxDrawn = true
    end
    return boxDrawn 
end


function writeTextArea(layer, imgLayer, contentLines, styles, xPos, yPos, width, height, paddingX, paddingY, boxLayer, boxBackgroundRgba)
    -- see documentation for parameters    

    -- get line total from content
    local totalLines = getLineCount(contentLines, styles)
    
    -- set text area parameters
    local rx, ry = getResolution() -- Gets the resolution of the screen

    local box = getBoxProperties(totalLines, xPos, yPos, width, height)
    local textArea = getTextAreaProperties(totalLines, paddingX, paddingY, box)

    -- *** draw background box ***
    if boxLayer then
        box.boxBackgroundColor = boxBackgroundRgba or {}
        drawBox(boxLayer, box)
    end

    -- loop over content lines
    local line = defaultLineHeight / 2 -- top of next line; start half a line down from top
    for i = 1, #contentLines do

        -- *** write one line of text or image ***

        -- style attributes
        local style = contentLines[i].style or defaultStyleName
        local font=styles[style].font or styles[defaultStyleName].font
        local textAlign=(contentLines[i].align or (styles[style].align or (styles[defaultStyleName].align or defaultTextAlign)))
        local colorRgba=(contentLines[i].colorRgba or (styles[style].colorRgba or (styles[defaultStyleName].colorRgba or {255,255,255,1.0})))
        local lineHeight=(contentLines[i].lineHeight or (styles[style].lineHeight or (styles[defaultStyleName].lineHeight or defaultLineHeight)))

        -- next line y pos
        local lineYpos = textArea.yPos + (line + lineHeight/2) * textArea.verticalPitch -- middle of item
        
        -- write text and image to screen
        if contentLines[i].imgPath then
            local img = getImageProperties(contentLines[i], line, lineHeight, textArea, textAlign)
            image = loadImage(contentLines[i].imgPath)
            addImage(imgLayer,image,img.posX,img.posY,img.width,img.height)
        end
        if contentLines[i].message then 
            setNextFillColor(layer, normaliseRgba(colorRgba) )
            if textAlign=="left" then
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, contentLines[i].message, textArea.leftPos, lineYpos)
            elseif textAlign=="right" then
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font, contentLines[i].message, textArea.rightPos, lineYpos)
            else
                setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
                addText(layer, font, contentLines[i].message, textArea.centerPos, lineYpos)
            end
        end
        
        -- next line
        line = line + lineHeight

    end

end 

main()